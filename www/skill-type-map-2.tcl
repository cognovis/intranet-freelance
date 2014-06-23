ad_page_contract {
    Set the display mode for the specific acs_object_type.
    Takes an arrray (all the radio-buttons from the page),
    compares it with the currently configured settings and
    changes those settings that are different.
    
    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    @cvs-id $Id$
} {
    category_type:notnull
    return_url:notnull
    attrib:array
}

# --------------------------------------------------------------
# Defaults & Security

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}


# --------------------------------------------------------------
# Get the information about the map and stuff it into a hash array
# for convenient matrix display.

set sql "
	select  skill_type_id,
	        object_type_id,
	        display_mode,
            category
	from    im_freelance_skill_type_map, im_categories
	where
            category_type = :category_type
            and category_id = object_type_id
	order by
		category
"

    
db_foreach skill_table_map $sql {
    set key "$skill_type_id.$object_type_id"
    set hash($key) $display_mode
}


# --------------------------------------------------------------
# Compare the information from "attrib" and "hash"

foreach key [array names attrib] {

    # New value from parameter
    set new_val $attrib($key)

    # Old value from database
    set old_val "none"
    set exists_p 0
    if {[info exists hash($key)]} { 
        set old_val $hash($key) 
        set exists_p 1
    }

    if {$new_val != $old_val} {

        if {[regexp {^([0-9]+)\.([0-9]+)$} $key match skill_type_id object_type_id]} {

	        ns_log Notice "skill_type-type-map-2: skill_type_id=$skill_type_id, object_type_id=$object_type_id, old_val=$old_val, new_val=$new_val"
	    
            if {$exists_p} {

                # Existed beforehand - perform an update
                if {"none" == $new_val} {
		    
                    db_dml delete_skill_type_map "
                        delete from im_freelance_skill_type_map
                        where skill_type_id = :skill_type_id
                        and object_type_id = :object_type_id

		                "
		    
                } else {
                    db_dml update_freelance_skill_type_map "
                        update im_freelance_skill_type_map
                        set display_mode = :new_val
                        where
                            skill_type_id = :skill_type_id
                        and object_type_id = :object_type_id
                        "
                }

            } else {

                # Didn't exist before - insert
                db_dml insert_im_freelance_skill_type_map "
                    insert into im_freelance_skill_type_map (
                        skill_type_id, object_type_id, display_mode
                    ) values (
                        :skill_type_id, :object_type_id, :new_val
                    )
		        "
	        }
        }
    }
}


# --------------------------------------------------------------

ad_returnredirect $return_url



