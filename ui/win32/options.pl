#!/usr/bin/perl -w

# options.pl: generate options dialog boxes

# Copyright (c) 2001-2015 Philip Kendall, Marek Januszewski, Stuart Brady

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Author contact information:

# E-mail: philip-fuse@shadowmagic.org.uk

use strict;

use Fuse;
use Fuse::Dialog;

die "No data file specified" unless @ARGV;
my %combo_sets;
my %combo_default;

my @dialogs = Fuse::Dialog::read( shift @ARGV );

print Fuse::GPL( 'options.c: options dialog boxes',
                 '2001-2013 Philip Kendall, Marek Januszewski, Stuart Brady' ) . << "CODE";

/* This file is autogenerated from options.dat by options.pl.
   Do not edit unless you know what you\'re doing! */

#include "config.h"

#ifdef UI_WIN32                /* Use this file if we're using WIN32 */

#include "libspectrum.h"

#include "display.h"
#include "fuse.h"
#include "menu.h"
#include "options.h"
#include "options_internals.h"
#include "periph.h"
#include "settings.h"
#include "ui/win32/win32internals.h"
#include "utils.h"

static int
option_enumerate_combo( const char * const *options, char *value, int count,
                        int def ) {
  int i;
  if( value != NULL ) {
    for( i = 0; i < count; i++) {
      if( !strcmp( value, options[ i ] ) )
        return i;
    }
  }
  return def;
}

CODE

foreach( @dialogs ) {

    foreach my $widget ( @{ $_->{widgets} } ) {

	foreach my $type ( $widget->{type} ) {

	    my $text = $widget->{text}; $text =~ tr/()//d;

	    if( $type eq "Combo" ) {
		my $n = 0;

		foreach( split( /\|/, $widget->{data1} ) ) {
		    if( /^\*/ ) {
			$combo_default{$widget->{value}} = $n;
		    }
		    $n++;
		}
		$n = 0;
		$widget->{data1} =~ s/^\*//;
		$widget->{data1} =~ s/\|\*/|/;
		if( not exists( $combo_sets{$widget->{data1}} ) ) {
		    $combo_sets{$widget->{data1}} = "$_->{name}_$widget->{value}_combo";

		    print << "CODE";

static const char * const $_->{name}_$widget->{value}_combo[] = {
CODE
		    foreach( split( /\|/, $widget->{data1} ) ) {
			print << "CODE";
  "$_",
CODE
			$n++;
		    }
		    print << "CODE";
};

static const int $_->{name}_$widget->{value}_combo_count = $n;

CODE
		} else {
		    print << "CODE";
\#define $_->{name}_$widget->{value}_combo $combo_sets{$widget->{data1}}
\#define $_->{name}_$widget->{value}_combo_count $combo_sets{$widget->{data1}}_count

CODE
		}
		print << "CODE";
int
option_enumerate_$_->{name}_$widget->{value}( void ) {
  return option_enumerate_combo( $_->{name}_$widget->{value}_combo,
                                 settings_current.$widget->{value},
                                 $_->{name}_$widget->{value}_combo_count,
                                 $combo_default{$widget->{value}} );
}

CODE
	    }
	}
    }

    my $idcname = uc( "IDC_OPT_$_->{name}" );
    my $optname = uc( "OPT_$_->{name}" );

print << "CODE";
static void
menu_options_$_->{name}_init( HWND hwndDlg )
{
  char buffer[80];
  int i;

  i = 0;
  buffer[0] = '\\0';
  if( buffer[i] ) {};          /* Shut gcc up */

CODE
    foreach my $widget ( @{ $_->{widgets} } ) {
	my $type = $widget->{type};

	if( $type eq "Checkbox" ) {
	    my $idcname = uc( "$widget->{value}" );
        print << "CODE";
  SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, BM_SETCHECK,
    settings_current.$widget->{value} ? BST_CHECKED : BST_UNCHECKED, 0 );

CODE
	} elsif( $widget->{type} eq "Entry" ) {
	    my $idcname = uc( "$widget->{value}" );
        print << "CODE";
  SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, EM_LIMITTEXT,
                      $widget->{data1}, 0 );
  /* FIXME This is asuming SendDlgItemMessage is not UNICODE */
  snprintf( buffer, 80, "%d", settings_current.$widget->{value} );
  SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, WM_SETTEXT,
                      0, (LPARAM) buffer );

CODE
	} elsif( $type eq "Combo" ) {
          my $idcname = uc( "$widget->{value}" );
          print << "CODE";
  for( i = 0; i < $_->{name}_$widget->{value}_combo_count; i++ ) {
    /* FIXME This is asuming SendDlgItemMessage is not UNICODE */
    SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, CB_ADDSTRING,
                        0, (LPARAM) $_->{name}_$widget->{value}_combo[i] );
  }
  SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, CB_SETCURSEL,
                      (LPARAM) $combo_default{$widget->{value}}, 0 );
  if( settings_current.$widget->{value} != NULL ) {
    for( i = 0; i < $_->{name}_$widget->{value}_combo_count; i++ ) {
      if( !strcmp( settings_current.$widget->{value},
                   $_->{name}_$widget->{value}_combo[i] ) ) {
        SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname},
                            CB_SETCURSEL, i, 0 );
      }
    }
  }
CODE
	} else {
          die "Unknown type `$type'";
        }
    }

print << "CODE";
}

static void
menu_options_$_->{name}_done( HWND hwndDlg )
{
  char buffer[80];

  buffer[0] = '\\0';
  if( buffer[0] ) {};          /* Shut gcc up */

CODE

    if( $_->{postcheck} ) {

      print << "CODE";
  /* Get a copy of current settings */
  settings_info original_settings;
  memset( &original_settings, 0, sizeof( settings_info ) );
  settings_copy( &original_settings, &settings_current );

CODE

    }

    foreach my $widget ( @{ $_->{widgets} } ) {
	my $type = $widget->{type};

	if( $type eq "Checkbox" ) {
	    my $idcname = uc( "$widget->{value}" );

	    print << "CODE";
  settings_current.$widget->{value} =
    IsDlgButtonChecked( hwndDlg, IDC_${optname}_${idcname} );

CODE
	} elsif( $widget->{type} eq "Entry" ) {
	    my $idcname = uc( "$widget->{value}" );
        print << "CODE";
  /* FIXME This is asuming SendDlgItemMessage is not UNICODE */
  SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, WM_GETTEXT,
                      80, (LPARAM) buffer );
  settings_current.$widget->{value} = atoi( buffer );

CODE
	} elsif( $widget->{type} eq "Combo" ) {
	    my $idcname = uc( "$widget->{value}" );
	    print << "CODE";
  libspectrum_free( settings_current.$widget->{value} );
  settings_current.$widget->{value} =
    utils_safe_strdup( $_->{name}_$widget->{value}_combo[
    SendDlgItemMessage( hwndDlg, IDC_${optname}_${idcname}, CB_GETCURSEL, 0, 0 ) ] );

CODE
        } else {
          die "Unknown type `$widget->{type}'";
        }
    }

    if( $_->{postcheck} ) {

      print << "CODE";
  int needs_hard_reset = $_->{postcheck}();

  /* Confirm reset */
  if( needs_hard_reset ) {
    ShowWindow( hwndDlg, SW_HIDE );

    if( !win32ui_confirm("Some options need to reset the machine. Reset?" ) ) {
      /* Cancel new settings */
      settings_copy( &settings_current, &original_settings );
      settings_free( &original_settings );

      ShowWindow( hwndDlg, SW_SHOW );
      return;
    }
  }

  settings_free( &original_settings );

CODE
    }

    print "  $_->{posthook}();\n\n" if $_->{posthook};

    print << "CODE";
  win32statusbar_set_visibility( settings_current.statusbar );
  display_refresh_all();

  EndDialog( hwndDlg, 0 );
}

static BOOL CALLBACK
menu_options_$_->{name}_proc( HWND hwndDlg, UINT msg, WPARAM wParam GCC_UNUSED,
                              LPARAM lParam GCC_UNUSED )
{
  switch( msg )
  {
    case WM_INITDIALOG:
    {
      /* FIXME: save the handle returned by LoadIcon() in win32ui.c */
      SendMessage( hwndDlg, WM_SETICON, ICON_SMALL,
                   (LPARAM)LoadIcon( fuse_hInstance, "win32_icon" ) );

      /* initialize the controls with current settings */
      menu_options_$_->{name}_init( hwndDlg );

      return TRUE;
    }

    case WM_COMMAND:
      switch( LOWORD( wParam ) )
      {
        case IDOK:
          /* Read the controls and apply the settings */
          menu_options_$_->{name}_done( hwndDlg );
          return 0;

        case IDCANCEL:
          EndDialog( hwndDlg, 0 );
          return 0;
      }
      break;

    case WM_CLOSE:
      EndDialog( hwndDlg, 0 );
      return 0;
  }

  return FALSE;
}

void
menu_options_$_->{name}( int action GCC_UNUSED )
{
  fuse_emulation_pause();

  DialogBox( fuse_hInstance, MAKEINTRESOURCE( IDD_$optname ),
             fuse_hWnd, (DLGPROC) menu_options_$_->{name}_proc );

  fuse_emulation_unpause();
}

CODE
}

    print << "CODE";

#endif                 /* #ifdef UI_WIN32 */

CODE
