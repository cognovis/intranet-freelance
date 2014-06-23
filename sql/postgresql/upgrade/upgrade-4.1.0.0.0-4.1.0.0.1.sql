-- 4.1.0.0.0-4.1.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-freelance/sql/postgresql/upgrade/upgrade-4.1.0.0.0-4.1.0.0.1.sql','');

-- Update to use aux_string1 for the categories
update im_categories set aux_string1=category_description where category_type = 'Intranet Skill Type' and aux_string1 is null;

-- Skill mapping to object types
-- Shamelessly inspired by dynfield type_attribute mapping

create table im_freelance_skill_type_map (
	skill_type_id		integer
				constraint im_freelance_skill_type_map_stype_nn
				not null
				constraint im_freelance_skill_type_map_stype_fk
				references im_categories,
	object_type_id		integer
				constraint im_freelance_skill_type_map_otype_nn
				not null
				constraint im_freelance_skill_type_map_otype_fk
				references im_categories,
	display_mode		varchar(10)
				constraint im_freelance_skill_type_map_dmode_nn
				not null
				constraint im_freelance_skill_type_map_dmode_ck
				check (display_mode in ('edit', 'display', 'none')),
	help_text		text,
	unique (skill_type_id, object_type_id)
);

-- Insert Skills for source / targetlangauge for each project_type

-- Translation projects need the object_ids from 2000 - 2019

create or replace function inline_0 () 
returns varchar as $body$
declare
        row                     RECORD;
        row2                     RECORD;
BEGIN
        FOR row IN
                select  c.category_id as skill_type_id
                from    im_categories c
                where   c.category_id <2020 and c.category_id >=2000
        LOOP
	 FOR row2 IN 
                select child_id as object_type_id from im_category_hierarchy where parent_id = 2500 union select 2500 as object_type_id from dual
         LOOP
	 insert into im_freelance_skill_type_map (skill_type_id,object_type_id,display_mode) values (row.skill_type_id,row2.object_type_id,'edit');		
         END LOOP;

        end loop;
        RETURN 0;
end;$body$ language 'plpgsql';

select inline_0();
drop function inline_0();

-- Consulting projects need the categories from 2020 - 2039
create or replace function inline_0 () 
returns varchar as $body$
declare
        row                     RECORD;
        row2                     RECORD;
BEGIN
        FOR row IN
                select  c.category_id as skill_type_id
                from    im_categories c
                where   c.category_id <2040 and c.category_id >=2020
        LOOP
	 FOR row2 IN 
                select child_id as object_type_id from im_category_hierarchy where parent_id = 2501 union select 2501 as object_type_id from dual
         LOOP
	 insert into im_freelance_skill_type_map (skill_type_id,object_type_id,display_mode) values (row.skill_type_id,row2.object_type_id,'edit');		
         END LOOP;

        end loop;
        RETURN 0;
end;$body$ language 'plpgsql';

select inline_0();
drop function inline_0();
