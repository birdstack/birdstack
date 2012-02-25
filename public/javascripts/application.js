
jQuery(function() {
    function doPagination(url, data, target, target_working) {
        jQuery(target).hide();
        jQuery(target_working).show();
        jQuery.get(url, data, null, "script");
    }

    jQuery('div.pagination-map a').live('click', function() {
        doPagination(this.href, null, "#pagination-content-map", "#pagination-working-map");
        return false;
    });

    jQuery('div.pagination-map-form form').live('submit', function() {
        doPagination(this.action, jQuery(this).serialize(), "#pagination-content-map", "#pagination-working-map");
        return false;
    });

    jQuery('div.pagination a').live('click', function() {
        doPagination(this.href, null, "#pagination-content", "#pagination-working");
        return false;
    });

    jQuery('div.pagination_form form').live('submit', function() {
        doPagination(this.action, jQuery(this).serialize(), "#pagination-content", "#pagination-working");
        return false;
    });

    jQuery('div.pagination-sighting-photos a').live('click', function() {
        doPagination(this.href, null, "#pagination-content-sighting-photos", "#pagination-working-sighting-photos");
        return false;
    });

    jQuery('div.pagination-user-location-photos a').live('click', function() {
        doPagination(this.href, null, "#pagination-content-user-location-photos", "#pagination-working-user-location-photos");
        return false;
    });

    jQuery('div.pagination-trip-photos a').live('click', function() {
        doPagination(this.href, null, "#pagination-content-trip-photos", "#pagination-working-trip-photos");
        return false;
    });
});

function greySubmits() {
  $$("input[type='submit']").each(function(e){e.disable()})
}

