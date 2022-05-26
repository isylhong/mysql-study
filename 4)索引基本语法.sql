******************** 索引基本语法 start ********************

1）创建索引
方法一：
CREATE [UNIQUE] INDEX 索引名 ON 表名(字段名);
方法二：
ALTER TABLE 表名 ADD [UNIQUE] INDEX 索引名 ON 表名(字段名);

2）删除索引
DROP INDEX 索引名 ON 表名;

3）查看索引
SHOW INDEX FROM 表名;

******************** 索引基本语法 end ********************



-- 为tbl_employee表(id,emp_name)字段创建复合索引
CREATE INDEX idx_emp_nameAgeDno ON tbl_employee(emp_name,emp_age,dept_no);

-- 为tbl_employee表(id,dept_no)字段创建复合索引
CREATE INDEX idx_dept_noName ON tbl_department(dept_no,dept_name);



-- 查看tbl_employee表已创建的索引
SHOW INDEX FROM tbl_employee;

-- 查看tbl_employee表已创建的索引
SHOW INDEX FROM tbl_department;



-- 删除tbl_employee表的idx_id_empname索引
DROP INDEX idx_emp_nameAgeDno ON tbl_employee;

-- 删除tbl_employee表的idx_id_deptno索引
DROP INDEX idx_dept_noName ON tbl_department;



