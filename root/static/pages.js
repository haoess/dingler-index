jQuery(document).ready( function() {
  // page switcher
  jQuery('#pageswitch').change( function() {
    var page = jQuery(this).val();
    var href = window.location.href;
    href = href.replace(/\?p=[0-9]+/, ''); // remove the ?p=... from href
    window.location.href = href + '?p=' + page;
  });

  jQuery('#text-container').height( jQuery('#scan').height() );
});
