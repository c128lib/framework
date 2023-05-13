#!/usr/bin/perl
#
# asm4doxy.pl - A script which transforms specially-formatted assembly
#   language files into something Doxygen can understand.
#
#   Copyright (C) 2007-2008 Bogdan 'bogdro' Drozdowski
#       (bogdandr AT op.pl, bogdro AT rudy.mif.pg.gda.pl)
#
#   License: GNU General Public Licence v3+
#
#   Last modified : 2008-05-18
#
#   Syntax:
#       ./asmdoc.pl aaa.asm bbb.asm ccc/ddd.asm
#       ./asmdoc.pl --help|-help|-h
#
#   Documentation comments should start with ';;' or '/**' and
#    end with ';;' or '*/'.
#
#   Examples:
#
#   ;;
#   ; This procedure reads data.
#   ; @param CX - number of bytes
#   ; @return DI - address of data
#   ;;
#   procedure01:
#       ...
#       ret
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation:
#       Free Software Foundation
#       51 Franklin Street, Fifth Floor
#       Boston, MA 02110-1301
#       USA
 
use strict;
use warnings;
use Cwd;
use File::Spec::Functions ':ALL';
use Getopt::Long;
use PerlIO::encoding;
 
 
if ( @ARGV == 0 ) {
    print_help();
    exit 1;
}
 
Getopt::Long::Configure("ignore_case", "ignore_case_always");
 
my $help='';
my $lic='';
my $encoding='iso-8859-1';
 
if ( !GetOptions (
    'encoding=s'        => \$encoding,
    'h|help|?'      => \$help,
    'license|licence|l' => \$lic,
    )
   )
{
    print_help();
    exit 2;
}
 
if ( $lic )
{
    print   "Asm4doxy - a program for converting specially-formatted assembly\n".
        "language files into something Doxygen can understand.\n".
        "See http://rudy.mif.pg.gda.pl/~bogdro/inne\n".
        "Author: Bogdan 'bogdro' Drozdowski, bogdro # rudy.mif.pg.gda.pl.\n\n".
        "    This program is free software; you can redistribute it and/or\n".
        "    modify it under the terms of the GNU General Public License\n".
        "    as published by the Free Software Foundation; either version 3\n".
        "    of the License, or (at your option) any later version.\n\n".
        "    This program is distributed in the hope that it will be useful,\n".
        "    but WITHOUT ANY WARRANTY; without even the implied warranty of\n".
        "    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n".
        "    GNU General Public License for more details.\n\n".
        "    You should have received a copy of the GNU General Public License\n".
        "    along with this program; if not, write to the Free Software Foundation:\n".
        "       Free Software Foundation\n".
        "       51 Franklin Street, Fifth Floor\n".
        "       Boston, MA 02110-1301\n".
        "       USA\n";
    exit 1;
}
 
# if "HELP" is on the command line or no files are given, print syntax
if ( $help || @ARGV == 0 )
{
    print_help();
    exit 1;
}
 
my ($dysk, $katalog, undef) = splitpath(cwd(), 1);
 
my @pliki = sort @ARGV;
my %pliki_oryg;
foreach my $p (@pliki)
{
    my $nowy;
    ($nowy = $p);# =~ s/\./-/g;
    $nowy = (splitpath $nowy)[2];
    $pliki_oryg{$nowy} = (splitpath $p)[2]; # =$p;
}
 
$encoding     =~ tr/A-Z/a-z/;
 
# The hashes go like this:
# file_description, file_variables, file_functions, file_variables_description,
# file_function_description, file_variable_values, file_structures, file_structrues_description,
# file_structure_variables, file_structure_variables_description, file_structure_variables_values,
# file_macros, file_macros_description, file_includes, file_variables_type, file_structure_variables_types
my (%pliki_opis, %pliki_zmienne, %pliki_funkcje, %pliki_zmienne_opis, %pliki_funkcje_opis,
    %pliki_zmienne_wartosci, %pliki_struktury, %pliki_struktury_opis, %pliki_struktury_zmienne,
    %pliki_struktury_zmienne_opis, %pliki_struktury_zmienne_wartosci,
    %pliki_makra, %pliki_makra_opis, %pliki_include, %pliki_zmienne_typy,
    %pliki_struktury_zmienne_typy);
 
# =================== Reading input files =================
foreach my $p (@pliki)
{
    # Hash array key is the filename with dashes instead of dots.
    my $key;
    $key = (splitpath $p)[2];
    #$key =~ s/\./-/g;
 
    # Current variable (or function) and its description:
    # (current_variable, current_variable_description, current_variable_value, function,
    #   type, structure, inside_struc, structure name, macro, current_type)
    my ($aktualna_zmienna, $aktualna_zmienna_opis, $aktualna_zmienna_wartosc, $funkcja, $typ,
        $struktura, $inside_struc, $struc_name, $makro, $aktualny_typ);
    $typ = 0;
    $funkcja = 0;
    $struktura = 0;
    $inside_struc = 0;
    $struc_name = "";
    $makro = 0;
    my $jest_opis;
 
    $pliki_zmienne{$key} = ();
    $pliki_funkcje{$key} = ();
    $pliki_struktury{$key} = ();
    $pliki_makra{$key} = ();
    $pliki_include{$key} = "";
 
    open(my $asm, "<:encoding($encoding)", catpath($dysk, $katalog, $p)) or
        die "$0: ".catpath($dysk, $katalog, $p).": $!\n";
 
    $jest_opis = 0;
    # find file description, if it exists
    OPISGL: while ( <$asm> )
    {
        next if /^\s*$/;
        $typ = 1 if ( /^\s*;;/ && $typ == 0 );
        $typ = 2 if ( /^\s*\/\*\*/ && $typ == 0 );
 
        if ( /^\s*[\%\#]?include\s*['"]?([\\\/\w\.\-\!\~\(\)\$\@]+)['"]?/i )
        {
            $pliki_include{$key} .= "$1 ";
        }
 
        if ( $typ == 1 )
        {
            last OPISGL if ( (! /^\s*;/) || /^\s*;;\s*$/ && $jest_opis );
        }
        elsif ( $typ == 2 )
        {
            last OPISGL if /^\s*\*\/\s*$/;
        }
 
        # removing leading comment characters from the beginning of the line
        s/^\s*;+//  if $typ == 1;
        s/^\s*\/?\*+// if $typ == 2;
 
        $pliki_opis{$key} .= $_ if $typ != 0;
        $jest_opis = 1;
    }
 
    if ( ! defined $_ )
    {
        close $asm;
        next;
    }
 
    if ( /^\s*;;\s*$/ || /^\s*\*\/\s*$/ )
    {
        $_ = <$asm>;
        if ( /^\s*[\%\#]?include\s*['"]?([\\\/\w\.\-\!\~\(\)\$\@]+)['"]?/i )
        {
            $pliki_include{$key} .= "$1 ";
        }
    }
 
    # if the first comment wasn't about the file
    if ( ! /^\s*$/ )
    {
        # variable/type 1 constant (xxx equ yyy)
        if ( /^\s*([\.\w]+)(:|\s+)\s*((times\s+\w+|(d|r|res)[bwudpfqt]\s|equ\s|=)+)\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/i )
        {
            my ($m1, $m3, $m5);
            $m1 = $1;
            $m3 = $3;
            $m5 = $6;
            # Can't be in a structure yet!
            $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $m1;
            $pliki_zmienne_opis{$key}{$m1} = $pliki_opis{$key};
            $pliki_zmienne_typy{$key}{$m1} = "$m3 $m5";
 
            $funkcja = 0;
            my $wartosc = $m5;
            if ( $m3 =~ /equ/i || $m3 =~ /=/ )
            {
                # Can't be in a structure yet!
                $pliki_zmienne_wartosci{$key}{$m1} = $wartosc;
            }
            else
            {
                # Can't be in a structure yet!
                $pliki_zmienne_wartosci{$key}{$m1} = "";
            }
        }
        # type 2 constant (.equ xxx yyy)
        elsif ( /^\s*\.equ?\s*(\w+)\s*,\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/i )
        {
            # Can't be in a structure yet!
            $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $1;
            $pliki_zmienne_opis{$key}{$1} = $pliki_opis{$key};
            $pliki_zmienne_wartosci{$key}{$1} = $2;
        }
        # traditional procedure beginning
        elsif ( /^\s*(\w+)(:|\s*(proc|near|far){1,2})\s*($|;.*$)/i )
        {
            $pliki_funkcje{$key}[++$#{$pliki_funkcje{$key}}] = $1;
            $pliki_funkcje_opis{$key}{$1} = $pliki_opis{$key};
        }
        # HLA syntax procedure
        elsif ( /^\s*proc(edure)?\s+(\w+)/i )
        {
            $pliki_funkcje{$key}[++$#{$pliki_funkcje{$key}}] = $2;
            $pliki_funkcje_opis{$key}{$2} = $pliki_opis{$key};
        }
        # structures
        elsif ( /^\s*struc\s+(\w+)/i )
        {
            $pliki_struktury{$key}[++$#{$pliki_struktury{$key}}] = $1;
            $pliki_struktury_opis{$key}{$1} = $pliki_opis{$key};
            $struktura = 1;
            $inside_struc = 1;
            $struc_name = $1;
        }
        # macros
        elsif ( /^\s*((\%i?)?|\.)macro\s+(\w+)/i )
        {
            $pliki_makra{$key}[++$#{$pliki_makra{$key}}] = $3;
            $pliki_makra_opis{$key}{$3} = $pliki_opis{$key};
        }
        elsif ( /^\s*(\w+)\s+macro/i )
        {
            $pliki_makra{$key}[++$#{$pliki_makra{$key}}] = $1;
            $pliki_makra_opis{$key}{$1} = $pliki_opis{$key};
        }
        # structure instances in NASM
        elsif ( /^\s*(\w+):?\s+istruc\s+(\w+)/i )
        {
            $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $1;
            $pliki_zmienne_opis{$key}{$1} = $pliki_opis{$key};
            $pliki_zmienne_typy{$key}{$1} = "istruc $2";
        }
        # dup()
        elsif ( /^\s*(\w+)\s+(d([bwudpfqt])\s+\w+\s*\(?\s*\bdup\b.*)/i )
        {
            $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $1;
            $pliki_zmienne_opis{$key}{$1} = $pliki_opis{$key};
            $pliki_zmienne_typy{$key}{$1} = "$2";
        }
        # some other type (like FASM structure instances)
        elsif ( /^\s*(\w+):?\s+(\w+)/i )
        {
            $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $1;
            $pliki_zmienne_opis{$key}{$1} = $pliki_opis{$key};
            $pliki_zmienne_typy{$key}{$1} = "$2";
        }
        undef($pliki_opis{$key});
    }
 
    while ( <$asm> )
    {
        if ( $inside_struc && /^\s*(endstruc|\})/i )
        {
            $struktura = 0;
            $inside_struc = 0;
        }
        if ( /^\s*[\%\#]?include\s*['"]?([\\\/\w\.\-\!\~\(\)\$\@]+)['"]?/i )
        {
            $pliki_include{$key} .= "$1 ";
        }
 
        # look for characters which start a comment
        next if ! ( /^\s*;;/ || /^\s*\/\*\*/ );
 
        $typ = 1 if /^\s*;;/;
        $typ = 2 if /^\s*\/\*\*/;
        $aktualna_zmienna_opis = $_;
        $aktualna_zmienna_opis =~ s/^\s*;+// if $typ == 1;
        $aktualna_zmienna_opis =~ s/^\s*\/?\*+// if $typ == 2;
 
        $jest_opis = 0;
        # Put all up to the first non-comment line into the current description
        while ( <$asm> )
        {
            next if /^\s*$/;
 
            if ( $typ == 1 )
            {
                last if ( (! /^\s*;/) || /^\s*;;\s*$/ && $jest_opis );
            }
            elsif ( $typ == 2 )
            {
                last if /^\s*\*\/\s*$/;
            }
 
            # removing leading comment characters from the beginning of the line
            s/^\s*;+//  if $typ == 1;
            s/^\s*\/?\*+// if $typ == 2;
 
            $aktualna_zmienna_opis .= $_ if $typ != 0;
            $jest_opis = 1;
        }
        if ( /^\s*;;\s*$/ || /^\s*\*\/\s*$/ )
        {
            $_ = <$asm>;
            if ( /^\s*[\%\#]?include\s*['"]?([\\\/\w\.\-\!\~\(\)\$\@]+)['"]?/i )
            {
                $pliki_include{$key} .= "$1 ";
            }
        }
 
        # finding the name of the variable or function
        # variable/type 1 constant (xxx equ yyy)
        if ( /^\s*([\.\w]+)(:|\s+)\s*((times\s+\w+|(d|r|res)[bwudpfqt]\s|equ\s|=)+)\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/i )
        {
            my ($m1, $m3, $m5);
            $m1 = $1;
            $m3 = $3;
            $m5 = $6;
            $aktualna_zmienna = $m1;
            $aktualny_typ = "$m3 $m5";
            $funkcja = 0;
            my $wartosc = $m5;
            if ( $m3 =~ /equ/i || $m3 =~ /=/ )
            {
                $aktualna_zmienna_wartosc = $wartosc;
            }
            else
            {
                $aktualna_zmienna_wartosc = "";
            }
        }
        # type 2 constant (.equ xxx yyy)
        elsif ( /^\s*\.equ?\s*([\w\.]+)\s*,\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/i )
        {
            $aktualna_zmienna = $1;
            $funkcja = 0;
            $aktualna_zmienna_wartosc = $2;
        }
        # traditional procedure beginning
        elsif ( /^\s*(\w+)(:|\s*(proc|near|far){1,2})\s*($|;.*$)/i )
        {
            $aktualna_zmienna = $1;
            $funkcja = 1;
            $aktualna_zmienna_wartosc = "";
        }
        # HLA syntax procedure
        elsif ( /^\s*proc(edure)?\s*(\w+)/i )
        {
            $aktualna_zmienna = $2;
            $funkcja = 1;
            $aktualna_zmienna_wartosc = "";
        }
        # structures
        elsif ( /^\s*struc\s+(\w+)/i )
        {
            $struc_name = $1;
            $funkcja = 0;
            $struktura = 1;
            $inside_struc = 0;
            $aktualna_zmienna_wartosc = "";
        }
        # macros
        elsif ( /^\s*((\%i?)?|\.)macro\s+(\w+)/i )
        {
            $aktualna_zmienna = $3;
            $makro = 1;
            $aktualna_zmienna_wartosc = "";
        }
        elsif ( /^\s*(\w+)\s+macro/i )
        {
            $aktualna_zmienna = $1;
            $makro = 1;
            $aktualna_zmienna_wartosc = "";
        }
        # structure instances in NASM
        elsif ( /^\s*(\w+):?\s+istruc\s+(\w+)/i )
        {
            $aktualna_zmienna = $1;
            $aktualna_zmienna_wartosc = "";
            $aktualny_typ = "istruc $2";
        }
        # dup()
        elsif ( /^\s*(\w+)\s+(d([bwudpfqt])\s+\w+\s*\(?\s*\bdup\b.*)/i )
        {
            $aktualna_zmienna = $1;
            $aktualna_zmienna_wartosc = "";
            $aktualny_typ = "$2";
        }
        # some other type (like FASM structure instances)
        elsif ( /^\s*(\w+):?\s+(\w+)/i )
        {
            $aktualna_zmienna = $1;
            $aktualna_zmienna_wartosc = "";
            $aktualny_typ = "$2";
        }
        else
        {
            chomp;
            print "$0: $p: '$_' ???\n";
            next;
        }
 
        # {@value}
        $aktualna_zmienna_opis =~ s/\{\s*(\@|\\)value\s*\}/$aktualna_zmienna_wartosc/ig;
 
        if ( $funkcja )
        {
            $pliki_funkcje{$key}[++$#{$pliki_funkcje{$key}}] = $aktualna_zmienna;
            $pliki_funkcje_opis{$key}{$aktualna_zmienna} = $aktualna_zmienna_opis;
        }
        elsif ( $struktura )
        {
            $pliki_struktury{$key}[++$#{$pliki_struktury{$key}}] = $struc_name;
            $pliki_struktury_opis{$key}{$struc_name} = $aktualna_zmienna_opis;
            $pliki_struktury_zmienne{$key}{$struc_name} = ();
            $pliki_struktury_zmienne_opis{$key}{$struc_name} = ();
            $pliki_struktury_zmienne_wartosci{$key}{$struc_name} = ();
            $inside_struc = 1;
            $struktura = 0;
        }
        elsif ( $makro )
        {
            $pliki_makra{$key}[++$#{$pliki_makra{$key}}] = $aktualna_zmienna;
            $pliki_makra_opis{$key}{$aktualna_zmienna} = $aktualna_zmienna_opis;
            $makro = 0;
        }
        else
        {
            if ( $inside_struc )
            {
                $pliki_struktury_zmienne{$key}{$struc_name}[++$#{$pliki_struktury_zmienne{$key}{$struc_name}}] = $aktualna_zmienna;
                $pliki_struktury_zmienne_opis{$key}{$struc_name}{$aktualna_zmienna} = $aktualna_zmienna_opis;
                $pliki_struktury_zmienne_wartosci{$key}{$struc_name}{$aktualna_zmienna} = $aktualna_zmienna_wartosc;
                $aktualna_zmienna =~ s/^\.//;
                $pliki_struktury_zmienne_typy{$key}{$struc_name}{$aktualna_zmienna} = $aktualny_typ;
            }
            else
            {
                $pliki_zmienne{$key}[++$#{$pliki_zmienne{$key}}] = $aktualna_zmienna;
                $pliki_zmienne_opis{$key}{$aktualna_zmienna} = $aktualna_zmienna_opis;
                $pliki_zmienne_wartosci{$key}{$aktualna_zmienna} = $aktualna_zmienna_wartosc;
                $pliki_zmienne_typy{$key}{$aktualna_zmienna} = $aktualny_typ;
 
            }
        }
    }
 
    close $asm;
 
    if ( $#{$pliki_zmienne{$key}} >= 0 )
    {
        my @posort = sort @{$pliki_zmienne{$key}};
        $pliki_zmienne{$key} = ();
        foreach (@posort) { push @{$pliki_zmienne{$key}}, $_; }
    }
 
    if ( $#{$pliki_struktury{$key}} >= 0 )
    {
        my @posort = sort @{$pliki_struktury{$key}};
        $pliki_struktury{$key} = ();
        foreach (@posort) { push @{$pliki_struktury{$key}}, $_; }
    }
 
    if ( $#{$pliki_funkcje{$key}} >= 0 )
    {
        my @posort = sort @{$pliki_funkcje{$key}};
        $pliki_funkcje{$key} = ();
        foreach (@posort) { push @{$pliki_funkcje{$key}}, $_; }
    }
 
}
 
# =================== Writing output files =================
foreach my $p (@pliki)
{
    # Hash array key is the filename with dashes instead of dots.
    my $key;
    $key = (splitpath $p)[2];
    # $key =~ s/\./-/g;
 
    # don't do anything if file would be empty
    next if !defined $pliki_opis{$key} && !defined $pliki_zmienne{$key} && !defined $pliki_funkcje{$key};
 
    $p = (splitpath $p)[2];
    if (not -d "./output/") {
      mkdir( "./output/", 0777) or die "Couldn't create output directory, $!";
    }
    open(my $dox, ">:encoding($encoding)", "output/".$key) or die "$0: $key: $!\n";
 
    if ( defined $pliki_opis{$key} )
    {
        print $dox "/**\n"
            ." * \\file $key.c\n"
            ." * \\brief $p\n\n"
            .$pliki_opis{$key}
            ."\n */\n\n\n";
    }
 
    if ( $pliki_include{$key} ne "" )
    {
        my @incl = split /\s+/, $pliki_include{$key};
        foreach (@incl)
        {
            print $dox "#include \"$_\"\n";
        }
        print $dox "\n";
    }
 
    # write C-style comments into the file for all documented functions
    # and variables/const. On each following line, write the variable/const
    # or a C-style function prototype.
 
    if ( defined($pliki_zmienne{$key}) && (@{$pliki_zmienne{$key}} > 0) )
    {
        foreach (@{$pliki_zmienne{$key}})
        {
            # check if variable or constant
            if ( defined  ($pliki_zmienne_wartosci{$key}{$_}) &&
                $pliki_zmienne_wartosci{$key}{$_} ne "" )
            {
                # constant
                print $dox "/**\n"
                    .$pliki_zmienne_opis{$key}{$_}
                    ."\n */\n"
                    ."#define $_ $pliki_zmienne_wartosci{$key}{$_}\n"
                    ;
            }
            else
            {
                # variable
                print $dox "/**\n"
                    .$pliki_zmienne_opis{$key}{$_}
                    ."\n */\n"
                    .do_variable($pliki_zmienne_typy{$key}{$_})."\n"
                    ;
            }
        }
    }
 
    if ( defined($pliki_funkcje{$key}) && (@{$pliki_funkcje{$key}} > 0) )
    {
        foreach (@{$pliki_funkcje{$key}})
        {
            my $func_proto = "";
#           if ( $pliki_funkcje_opis{$key}{$_} =~ /[\@\\]param[^\s]*\s+([\%\w]+):([\%\w]+)/i )
#           {
#               $pliki_funkcje_opis{$key}{$_} =~ s/[\@\\]param[^\s]*\s+([\%\w]+):([\%\w]+)/\@param $1$2/gi;
#           }
            print $dox "/**\n"
                .$pliki_funkcje_opis{$key}{$_}
                ."\n */\n";
            if ( $pliki_funkcje_opis{$key}{$_} !~ /[\@\\]return/i )
            {
                print $dox "void ";
            }
            print $dox "$_ (";
            while ($pliki_funkcje_opis{$key}{$_} =~ /[\@\\]param[^\s]*\s+([\w\:\/\(\)\[\]\%]+)/i)
            {
                my $par = $1;
                $par =~ s/\://g;
                $func_proto .= "$par, ";
                $pliki_funkcje_opis{$key}{$_} =~ s/[\@\\]param//i;
            }
            if ( $func_proto eq "" )
            {
                $func_proto = "void";
            }
            else
            {
                $func_proto =~ s/,\s*$//;
            }
            print $dox "$func_proto);\n";
        }
    }
 
    if ( defined($pliki_struktury{$key}) && (@{$pliki_struktury{$key}} > 0) )
    {
        foreach my $stru (@{$pliki_struktury{$key}})
        {
            if ( defined $pliki_struktury_opis{$key}{$stru} )
            {
                print $dox "/**\n"
                    .$pliki_struktury_opis{$key}{$stru}
                    ."\n */\n"
                    ."struct $stru \n{\n"
                    ;
            }
            if ( defined($pliki_struktury_zmienne{$key}{$stru})
                && (@{$pliki_struktury_zmienne{$key}{$stru}} > 0) )
            {
                foreach (@{$pliki_struktury_zmienne{$key}{$stru}})
                {
                    # check if variable or constant
                    if ( defined  ($pliki_struktury_zmienne_wartosci{$key}{$stru}{$_})
                        && $pliki_struktury_zmienne_wartosci{$key}{$stru}{$_} ne "" )
                    {
                        # constant
                        print $dox "/**\n"
                            .$pliki_struktury_zmienne_opis{$key}{$stru}{$_}
                            ."\n */\n"
                            ."#define $_ $pliki_struktury_zmienne_wartosci{$key}{$stru}{$_}\n"
                            ;
                    }
                    else
                    {
                        # variable
                        print $dox "/**\n"
                            .$pliki_struktury_zmienne_opis{$key}{$stru}{$_}
                            ."\n */\n"
                            ;
                        s/^\.//;
                        print $dox "\t".
                            do_variable($pliki_struktury_zmienne_typy{$key}{$stru}{$_}).
                            "\n"
                            ;
                    }
                }
            }
            print $dox "\n};\n";
        }
    }
 
    if ( defined($pliki_makra{$key}) && (@{$pliki_makra{$key}} > 0) )
    {
        foreach (@{$pliki_makra{$key}})
        {
            my $makro_proto = "";
#           if ( $pliki_makra_opis{$key}{$_} =~ /[\@\\]param[^\s]*\s+([\%\w]+):([\%\w]+)/i )
#           {
#               $pliki_makra_opis{$key}{$_} =~ s/[\@\\]param[^\s]*\s+([\%\w]+):([\%\w]+)/\@param $1$2/gi;
#           }
            if ( $pliki_makra_opis{$key}{$_} =~ /[\@\\]param[^\s]*\s+\%(\d+)/i )
            {
                $pliki_makra_opis{$key}{$_} =~ s/[\@\\]param[^\s]*\s+\%(\d+)/\@param par$1/gi;
            }
            print $dox "/**\n"
                .$pliki_makra_opis{$key}{$_}
                ."\n */\n"
                ."#define $_("
                ;
            while ($pliki_makra_opis{$key}{$_} =~ /[\@\\]param[^\s]*\s+([\w\:\/\(\)\[\]\%]+)/i)
            {
                my $mak_par = $1;
                $mak_par =~ s/\://g;
                $makro_proto .= "$mak_par, ";
                $pliki_makra_opis{$key}{$_} =~ s/[\@\\]param//i;
            }
            $makro_proto =~ s/,\s*$//;
            print $dox "$makro_proto) /* $pliki_oryg{$key}, $_ */\n";
        }
    }
 
    close $dox;
}
 
exit 0;
 
# ============================ print_help ===================================
 
sub print_help
{
    print   "Asm4doxy - a program for converting specially-commented assembly\n".
        "language files into something Doxygen can understand.\n".
        "See http://rudy.mif.pg.gda.pl/~bogdro/inne\n".
        "Syntax: $0 [options] files\n\n".
        "Options:\n".
        "-encoding <name>\t\tSource files' character encoding\n".
        "-h|--help|-help|-?\t\tShows the help screen\n".
        "-L|--license\t\t\tShows the license for this program\n\n".
        "Documentation comments should start with ';;' or '/**' and\n".
        "end with ';;' or '*/'.\n\n".
        "Examples:\n\n".
        ";;\n".
        "; This procedure reads data.\n".
        "; \@param CX - number of bytes\n".
        "; \@return DI - address of data\n".
        ";;\n".
        "procedure01:\n".
        "\t...\n".
        "\tret\n"
        ;
}
 
# ============================= do_variable ===================================
 
sub do_variable
{
    my $var;
    my $typ = shift;
    $var = "$_;";
    # parse the variable type here
    if ( defined ($typ) )
    {
        # times + resX/rX:
        if ( $typ =~ /\btimes\s+(\w+)\s+(r|res)([bwudpfqt])\s+(\w+)/i )
        {
            my $type = $3;
            my $liczba1 = $1;
            my $liczba2 = $4;
            if ( $liczba1 =~ /\d+h/i )
            {
                $liczba1 = "0x$liczba1";
                $liczba1 =~ s/h$//i;
            }
            elsif ( $liczba1 =~ /\d+[qo]/i )
            {
                $liczba1 = "0$liczba1";
                $liczba1 =~ s/[qo]$//i;
            }
            if ( $liczba2 =~ /\d+h/i )
            {
                $liczba2 = "0x$liczba2";
                $liczba2 =~ s/h$//i;
            }
            elsif ( $liczba2 =~ /\d+[qo]/i )
            {
                $liczba2 = "0$liczba2";
                $liczba2 =~ s/[qo]$//i;
            }
            if ( $type eq "b" )
            {
                $var = "char $_ [$liczba1*$liczba2];";
            }
            elsif ( $type eq "w" || $type eq "u" )
            {
                $var = "short $_ [$liczba1*$liczba2];";
            }
            elsif ( $type eq "d" )
            {
                $var = "Dword $_ [$liczba1*$liczba2]; /* 32-bit integer or float or pointer */";
            }
            elsif ( $type eq "p" || $type eq "f" )
            {
                $var = "far void * $_ [$liczba1*$liczba2]; /* 48-bit number */";
            }
            elsif ( $type eq "q" )
            {
                $var = "Qword $_ [$liczba1*$liczba2]; /* 64-bit integer or double or pointer */";
            }
            else #if ( $type eq "t" )
            {
                $var = "long double $_ [$liczba1*$liczba2]; /* 80-bit long double */";
            }
        }
        # times + dX
        elsif ( $typ =~ /\btimes\s+(\w+)\s+d([bwudpfqt])/i )
        {
            my $type = $2;
            my $liczba = $1;
            if ( $liczba =~ /\d+h/i )
            {
                $liczba = "0x$liczba";
                $liczba =~ s/h$//i;
            }
            elsif ( $liczba =~ /\d+[qo]/i )
            {
                $liczba = "0$liczba";
                $liczba =~ s/[qo]$//i;
            }
            if ( $type eq "b" )
            {
                $var = "char $_ [$liczba];";
            }
            elsif ( $type eq "w" || $type eq "u" )
            {
                $var = "short $_ [$liczba];";
            }
            elsif ( $type eq "d" )
            {
                $var = "Dword $_ [$liczba]; /* 32-bit integer or float or pointer */";
            }
            elsif ( $type eq "p" || $type eq "f" )
            {
                $var = "far void * $_ [$liczba]; /* 48-bit number */";
            }
            elsif ( $type eq "q" )
            {
                $var = "Qword $_ [$liczba]; /* 64-bit integer or double or pointer */";
            }
            else #if ( $type eq "t" )
            {
                $var = "long double $_ [$liczba]; /* 80-bit long double */";
            }
        }
        # dup():
        elsif  ( $typ =~ /^\s*d([bwudpfqt])\s+\w+\s*\(?\s*\bdup\b/i )
        {
            my $dim = 0;
            my @dims = ();
            my $type = $1;
            while ( $typ =~ /(\w+)\s*\(?\s*dup/i )
            {
                $dim++;
                push @dims, $1;
                $typ =~ s/(\w+)\s*\(?\s*dup//i;
            }
            if ( $type eq "b" )
            {
                $var = "char $_ ";
            }
            elsif ( $type eq "w" || $type eq "u" )
            {
                $var = "short $_ ";
            }
            elsif ( $type eq "d" )
            {
                $var = "Dword $_ ";
            }
            elsif ( $type eq "p" || $type eq "f" )
            {
                $var = "far void * $_ ";
            }
            elsif ( $type eq "q" )
            {
                $var = "Qword $_ ";
            }
            else #if ( $type eq "t" )
            {
                $var = "long double $_ ";
            }
            foreach my $i (@dims)
            {
                $var .= "[$i]";
            }
            $var .= ";";
        }
        # istruc:
        elsif  ( $typ =~ /\bistruc\s+(\w+)/i )
        {
            $var = "struct $1 $_;"
        }
        # resX / rX
        elsif  ( $typ =~ /\b(res|r)([bwudpfqt])\s+(\w+)/i )
        {
            my $type = $2;
            my $liczba = $3;
            if ( $liczba =~ /\d+h/i )
            {
                $liczba = "0x$liczba";
                $liczba =~ s/h$//i;
            }
            elsif ( $liczba =~ /\d+[qo]/i )
            {
                $liczba = "0$liczba";
                $liczba =~ s/[qo]$//i;
            }
            if ( $type eq "b" )
            {
                $var = "char $_ [$liczba];";
            }
            elsif ( $type eq "w" || $type eq "u" )
            {
                $var = "short $_ [$liczba];";
            }
            elsif ( $type eq "d" )
            {
                $var = "Dword $_ [$liczba]; /* 32-bit integer or float or pointer */";
            }
            elsif ( $type eq "p" || $type eq "f" )
            {
                $var = "far void * $_ [$liczba]; /* 48-bit number */";
            }
            elsif ( $type eq "q" )
            {
                $var = "Qword $_ [$liczba]; /* 64-bit integer or double or pointer */";
            }
            else #if ( $type eq "t" )
            {
                $var = "long double $_ [$liczba]; /* 80-bit long double */";
            }
        }
        # traditional d[bwudpfqt]
        elsif  ( $typ =~ /\bd([bwudpfqt])\s+(.*)$/i )
        {
            my $type;
            my $reszta;
            $type = $1;
            $reszta = $2;
            if ( $type eq "b" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "char $_ [];";
                }
                else
                {
                    $var = "char $_;";
                }
            }
            elsif ( $type eq "w" || $type eq "u" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "short $_ [];";
                }
                else
                {
                    $var = "short $_;";
                }
            }
            elsif ( $type eq "d" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "Dword $_ []; /* 32-bit integer or float or pointer */";
                }
                else
                {
                    $var = "Dword $_; /* 32-bit integer or float or pointer */";
                }
            }
            elsif ( $type eq "p" || $type eq "f" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "far void * $_ []; /* 48-bit number */";
                }
                else
                {
                    $var = "far void * $_; /* 48-bit number */";
                }
            }
            elsif ( $type eq "q" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "Qword $_ []; /* 64-bit integer or double or pointer */";
                }
                else
                {
                    $var = "Qword $_; /* 64-bit integer or double or pointer */";
                }
            }
            else #if ( $type eq "t" )
            {
                if ( $reszta =~ /["',]/ )
                {
                    $var = "long double $_ []; /* 80-bit long double */";
                }
                else
                {
                    $var = "long double $_; /* 80-bit long double */";
                }
            }
        }
        # other type given:
        else
        {
            $typ =~ /(\w+)/i;
            $var = "$1 $_;"
        }
    }
    return $var;
}
 
END { close(STDOUT) || die "$0: Can't close stdout: $!"; }
