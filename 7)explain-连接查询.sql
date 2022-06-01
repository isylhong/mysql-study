DROP INDEX idx_dept_No ON tbl_department;

SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

******************** start ********************

等值连接，驱动表与被驱动表：
  1）情形1：连接条件字段都是索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
  2）情形2：连接条件字段都是非索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
  3）情形3：连接条件字段中有一方为索引字段，则以涉及非索引字段的表为驱动表。

多表连接时，各type字段值的含义：
  1）type=eq_ref：表示连接条件中使用到的索引是唯一索引。
	2）type=ref：表示连接条件中使用到的索引是非唯一索引

注：多表连接要想使用索引，则该为连接的条件字段加索引。

******************** end ********************


1）情形1：连接条件字段都是索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.id = tbl_department.id;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.id = tbl_employee.id;

2）情形2：连接条件字段都是非索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.dept_no = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.dept_no;

3) 情形3：连接条件字段中有一方为索引字段，则以涉及非索引字段的表为驱动表。
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.id = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.id;

DROP INDEX idx_emp_deptNo ON tbl_employee;
CREATE INDEX idx_emp_deptNo ON tbl_employee(dept_no);
SHOW INDEX FROM tbl_employee;
-- type=ref, key=idx_emp_deptNo, ref=study_mysql.tbl_department.dept_no
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.dept_no = tbl_department.dept_no;



1）左连接,以左表为驱动表**
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_employee.id, extra=null
EXPLAIN SELECT * FROM tbl_employee LEFT JOIN tbl_department ON tbl_employee.id = tbl_department.id;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.id, extra=null
EXPLAIN SELECT * FROM tbl_department LEFT JOIN tbl_employee ON tbl_employee.id = tbl_department.id;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=all, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_employee LEFT JOIN tbl_department ON tbl_employee.id = tbl_department.dept_no;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.id, extra=null						
EXPLAIN SELECT * FROM tbl_department LEFT JOIN tbl_employee ON tbl_employee.id = tbl_department.dept_no;



2）右连接,以右表为驱动表
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.id, extra=null
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_employee.id = tbl_department.id;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_employee.id, extra=null
EXPLAIN SELECT * FROM tbl_department RIGHT JOIN tbl_employee ON tbl_employee.id = tbl_department.id;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.dept_no; extra=Using where
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_employee.id = tbl_department.dept_no;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=all, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_department RIGHT JOIN tbl_employee ON tbl_employee.id = tbl_department.dept_no;
