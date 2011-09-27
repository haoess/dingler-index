jQuery( function() {
  jQuery( '.v' ).each( function() {
    jQuery(this).html( '<div>' + jQuery(this).html() + '<\/div>' );
  });

  jQuery( '.v' ).css({
    'margin':'0',
    'padding':'0',
  });

  jQuery( '.v > div' ).css({
    'position':'relative',
    'margin':'0',
    'padding':'0',
    'white-space': 'nowrap',
    '-webkit-transform': 'rotate(-90deg)',
    'writing-mode': 'tb-rl',
    '-moz-transform': 'rotate(-90deg)',
    '-ms-transform': 'rotate(-90deg)',
    '-o-transform': 'rotate(-90deg)',
    'transform': 'rotate(-90deg)'
  });

  jQuery('.v > div').each( function() {
    jQuery( this ).css( 'min-width', jQuery( this ).width() );
    jQuery( this ).parent().height( jQuery(this).width() );
    jQuery( this ).parent().css( 'max-width', jQuery(this).height() );
    jQuery( this ).css( 'left', -1 * (jQuery(this).width() / 2 ) + jQuery(this).parent().width()/2 );
  });
});
