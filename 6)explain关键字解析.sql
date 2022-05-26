******************** start ********************

mysql索引结构为B树。
1) 创建了索引的字段会在索引节点中保存该字段值。
2) 无论创建什么类型索引（单值索引，复合索引，...），索引节点都会保存主键字段值。

extra=Using index
1) 表示只使用到索引节点中的部分(或全部)内容，未通过索引节点去磁盘查找其他字段内容。
2) where判断条件中使用到索引节点中的字段。

extra=Using where
1) 表示where判断条件中未使用到索引节点中的字段内容。

******************** end ********************



-- 查看建立的索引
SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

CALL dropIndex("study_mysql","tbl_employee","idx_emp_name");

******************** 1.只有主键索引 start ********************
（1）使用到索引
-- type=index,key=PRIMARY,extra=Using index
EXPLAIN SELECT id FROM tbl_employee;

（2）未使用索引
-- type=ALL,key=null,extra=null
EXPLAIN SELECT * FROM tbl_employee;
-- type=ALL,key=null,extra=null
EXPLAIN SELECT emp_name FROM tbl_employee;
-- type=ALL,key=null,extra=null
EXPLAIN SELECT dept_no FROM tbl_employee;
-- type=ALL,key=null,extra=null
EXPLAIN SELECT id,emp_name FROM tbl_employee;
-- type=ALL,key=null,extra=null
EXPLAIN SELECT id,dept_no FROM tbl_employee;
-- type=ALL,key=null,extra=null
EXPLAIN SELECT id,emp_name,dept_no FROM tbl_employee;


******************** 2.只有主键索引，使用where条件查询 ********************
（1）使用到索引
-- type=const,key=PRIMARY,extra=Using index
EXPLAIN SELECT id FROM tbl_employee WHERE id = 500;
-- type=const,key=PRIMARY,extra=null
EXPLAIN SELECT emp_name FROM tbl_employee WHERE id = 500;
-- type=const,key=PRIMARY,extra=null
EXPLAIN SELECT dept_no FROM tbl_employee WHERE id = 500;
-- type=const,key=PRIMARY,extra=null
EXPLAIN SELECT id,emp_name FROM tbl_employee WHERE id = 500;
-- type=const,key=PRIMARY,extra=null
EXPLAIN SELECT id,dept_no FROM tbl_employee WHERE id = 500;
-- type=const,key=PRIMARY,extra=null
EXPLAIN SELECT id,emp_name,dept_no FROM tbl_employee WHERE id = 500;

（2）未使用索引
-- type=all,key=null,extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = 'twdZMN';
-- type=all,key=null,extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE dept_no = 105;
-- type=all,key=null,extra=Using where
EXPLAIN SELECT id FROM tbl_employee WHERE emp_name = 'twdZMN';




******************** 3.为tbl_employee(emp_name)创建索引 ********************
CREATE INDEX idx_empname ON tbl_employee(emp_name);
SHOW INDEX FROM tbl_employee;

（1）使用到索引
-- type=ref,key=idx_empname,extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = 'FAMiHI';
-- type=ref,key=idx_empname,extra=Using index
EXPLAIN SELECT id FROM tbl_employee WHERE emp_name = 'FAMiHI';
-- type=ref,key=idx_empname,extra=Using index
EXPLAIN SELECT emp_name FROM tbl_employee WHERE emp_name = 'FAMiHI';

（2）未使用到索引
-- type=all,key=null,extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE dept_no = 105;




-- 查询员工名字无重复的数量
-- type=index,extra=using index
EXPLAIN SELECT COUNT(1) FROM (SELECT emp_name FROM tbl_employee GROUP BY emp_name) AS t1;
EXPLAIN SELECT COUNT(1) FROM (SELECT id FROM tbl_employee GROUP BY emp_name) AS t1;
EXPLAIN SELECT COUNT(1) FROM (SELECT id,emp_name FROM tbl_employee GROUP BY emp_name) AS t1;

-- type=index,extra=null
-- 需要通过索引节点去磁盘查询其他字段内容
EXPLAIN SELECT COUNT(1) FROM (SELECT dept_no FROM tbl_employee GROUP BY emp_name) AS t1;
EXPLAIN SELECT COUNT(1) FROM (SELECT * FROM tbl_employee GROUP BY emp_name) AS t1;




