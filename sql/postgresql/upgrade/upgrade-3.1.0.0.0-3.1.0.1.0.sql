


-- -----------------------------------------------------
-- Add privileges for freelance_skills and freelance_skills_hours
--
select acs_privilege__create_privilege('add_freelance_skills','Add Freelance Skills','Add Freelance Skills');
select acs_privilege__add_child('admin', 'add_freelance_skills');

select acs_privilege__create_privilege('view_freelance_skills','View Freelance Skills','View Freelance Skills');
select acs_privilege__add_child('admin', 'view_freelance_skills');

select im_priv_create('view_freelance_skills','Accounting');
select im_priv_create('view_freelance_skills','P/O Admins');
select im_priv_create('view_freelance_skills','Project Managers');
select im_priv_create('view_freelance_skills','Senior Managers');
select im_priv_create('view_freelance_skills','Freelance Managers');
select im_priv_create('view_freelance_skills','Employees');

select im_priv_create('add_freelance_skills','Accounting');
select im_priv_create('add_freelance_skills','P/O Admins');
select im_priv_create('add_freelance_skills','Senior Managers');
select im_priv_create('add_freelance_skills','Project Managers');
select im_priv_create('add_freelance_skills','Freelance Managers');



