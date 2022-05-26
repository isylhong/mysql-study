
DROP INDEX idx_deptno ON tbl_employee;
DROP INDEX idx_deptno ON tbl_department;

SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

******************** start ********************

等值连接，连接表查询执行顺序。
1）情形1：连接条件字段都是索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
2）情形2：连接条件字段都是非索引字段。以记录少的表为驱动表，与FROM关键字后的表书写顺序无管。（即，先查询记录少的表）
3）情形3：连接条件字段中有一方为索引字段。以非索引字段为比较条件的表驱动表。

注：多表连接要想使用索引，那么，连接的条件字段应该加索引。

******************** end ********************


1）情形1：
-- epxlian中type属性值为eq_ref：多表连接查询时，连接条件中出现索引字段，通过连接条件查询到唯一一条符合条件记录
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.id = tbl_department.id;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.id = tbl_employee.id;

-- 情形3：
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.id = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.id;


2）情形2:
-- 多表连接查询时，连接条件中未出现索引字段，epxlian中type属性值为all：
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.dept_no = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.dept_no;



CREATE INDEX idx_deptno ON tbl_employee(dept_no);
SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

3）情形3：
-- epxlian中type属性值为ref：多表连接查询时，连接条件中出现索引字段，且通过连接条件查找到多条符合条件记录
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.dept_no = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.dept_no;


DROP INDEX idx_deptno ON tbl_employee;
CREATE INDEX idx_deptno ON tbl_department(dept_no);
SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

-- 情形3：
EXPLAIN SELECT * FROM tbl_employee,tbl_department WHERE tbl_employee.dept_no = tbl_department.dept_no;
EXPLAIN SELECT * FROM tbl_department,tbl_employee WHERE tbl_department.dept_no = tbl_employee.dept_no;





-- 左连接,以左表为驱动表*************************************

-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=eq_ref, key=PRIMARY, extra=null
EXPLAIN SELECT * FROM tbl_employee LEFT JOIN tbl_department ON tbl_employee.id = tbl_department.id;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=all, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_employee LEFT JOIN tbl_department ON tbl_employee.dept_no = tbl_department.dept_no;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=all, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_employee LEFT JOIN tbl_department ON tbl_employee.id = tbl_department.dept_no;


-- 表(tbl_employee):type=index, key=PRIMARY, extra=Using index
-- 表(tbl_department):type=eq_ref, key=PRIMARY, extra=Using index
EXPLAIN SELECT te.id,td.id FROM tbl_employee te LEFT JOIN tbl_department td ON te.id = td.id;
-- 表(tbl_employee):type=index, key=PRIMARY, extra=Using index
-- 表(tbl_department):type=eq_ref, key=PRIMARY, extra=null
EXPLAIN SELECT te.id,td.dept_no FROM tbl_employee te LEFT JOIN tbl_department td ON te.id = td.id;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=eq_ref, key=PRIMARY, extra=Using index
EXPLAIN SELECT te.emp_name,td.id FROM tbl_employee te LEFT JOIN tbl_department td ON te.id = td.id;
-- 表(tbl_employee):type=all, extra=null
-- 表(tbl_department):type=eq_ref, key=PRIMARY, extra=null
EXPLAIN SELECT te.emp_name,td.dept_no FROM tbl_employee te LEFT JOIN tbl_department td ON te.id = td.id;





-- 右连接,以右表为驱动表***********************************

-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.id, extra=null
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_employee.id = tbl_department.id;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=all, key=null, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_employee.dept_no = tbl_department.dept_no;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=all, extra=Using where;Using join buffer (Block Nested Loop)
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_employee.dept_no = tbl_department.id;
-- 表(tbl_department):type=all, extra=null
-- 表(tbl_employee):type=eq_ref, key=PRIMARY, ref=study_mysql.tbl_department.dept_no; extra=Using where
EXPLAIN SELECT * FROM tbl_employee RIGHT JOIN tbl_department ON tbl_department.dept_no = tbl_employee.id;
