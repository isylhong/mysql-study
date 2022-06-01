******************** start ********************

mysql索引结构为B树。
1) 创建了索引的字段会在索引节点中保存该字段值。
2) 无论创建什么类型索引（单值索引，复合索引，...），索引节点都会保存主键字段值。


EXPLAIN中type各字段含义：type字段主要用于确定where比较中使用的字段是否存在于索引中，且使用到的是何种索引。
const: 
  1) 使用WHERE，且where的比较字段存在于索引中，且where中比较字段的值可以唯一确定一条记录(即：where中使用的比较字段是唯一性索引字段)。
	
eq_ref: 多表连接查询时，出现该类型。
  1) 连接条件中涉及的被驱动表中的字段是唯一索引字段。
注：等值连接时，连接的两表不区分书写顺序。外连接，如左连接时，连接判断条件中使用到的唯一索引字段必须是被驱动表（左连接时，左表为驱动表，右表为被驱动表）中的唯一索引字段。

ref: 
  1) 使用WHERE，且where的比较字段存在于索引中，且where中比较字段的值可能匹配到多条记录(即：where中使用的比较字段不是唯一性索引字段)。
	
range:
  1) 使用WHERE，且对Where中判断条件中涉及的索引字段使用了>、<、!=、is not null等范围比较。
	
index: 
  1) 未使用WHERE, 且要查询的字段都存在于索引中。
	2) 使用GROUP BY，且group by的分组字段存在于索引中。
	
ALL：
  1) 使用Where，且where中的比较字段不存在于索引中。 
	2) 未使用Where，且查询的字段中存在部分字段不在索引字段中。


EXPLAIN中extra各字段含义：
Using index：表示未通过索引节点去磁盘查找其他字段内容，所要查询的字段在索引中都保存有，用于确定要查询的字段是否存在于索引中。查询满足以下任意一个条件时，extra=Using index。
	1) 使用WHERE，且where的所有判断条件字段在索引中都存在，且查询的结果字段索引节点中都保存有。
	2) 未使用WHERE,且查询的结果字段索引节点中都保存有。
	
Using where：表示where判断条件中未使用到索引节点中的字段内容。查询满足以下任意一个条件时，extra=Using where。
  1) 使用WHERE，且where中使用的判断字段不存在于索引中。
	
Using temporary:
  1) 使用GROUP BY，且group by的分组字段不存在于索引中。 (未使用到索引情况下进行分组，会用到临时表）
	
Using filesort:
  1) 使用GROUP BY，且group by的分组字段不存在于索引中。
	1) 使用ORDER BY，且查询的字段中存在部分字段不在索引字段中。
	
	
******************** end ********************



-- 查看建立的索引
SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;
DROP INDEX idx_emp_name ON tbl_employee;


******************** 1.查询表只有主键(id)索引 start ********************
-- 不使用WHERE条件查询
-- type=index, key=PRIMARY, extra=Using index
EXPLAIN SELECT id FROM tbl_employee;
-- type=ALL, key=null, extra=null
EXPLAIN SELECT emp_name FROM tbl_employee;

-- 使用WHERE条件查询
-- type=const, key=PRIMARY, extra=Using index
EXPLAIN SELECT id FROM tbl_employee WHERE id = 500;
-- type=const, key=PRIMARY, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE id = 500;

-- type=all, key=null, extra=Using where
EXPLAIN SELECT id FROM tbl_employee WHERE dept_no = 105;
-- type=all, key=null, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE dept_no = 105;



******************** 2.为tbl_employee(emp_name)创建非唯一性索引 ********************
CALL dropIndex('study_mysql','tbl_employee','idx_emp_name');
CREATE INDEX idx_emp_name ON tbl_employee(emp_name);
SHOW INDEX FROM tbl_employee;

SELECT emp_name FROM tbl_employee GROUP BY emp_name HAVING count(1) >3;
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = '200.1';

-- type=ref, key=idx_emp_name, extra=Using index
EXPLAIN SELECT id FROM tbl_employee WHERE emp_name = 'VDELTL';
-- type=ref, key=idx_emp_name, extra=Using index
EXPLAIN SELECT emp_name FROM tbl_employee WHERE emp_name = 'VDELTL';
-- type=ref, key=idx_emp_name, extra=null
EXPLAIN SELECT id,emp_name,emp_age FROM tbl_employee WHERE emp_name = 'VDELTL';

-- 嵌套查询，查询员工不同名字个数
-- type=index, extra=using index
EXPLAIN SELECT COUNT(1) FROM (SELECT id FROM tbl_employee GROUP BY emp_name) AS t1;
-- type=index, extra=null
EXPLAIN SELECT COUNT(1) FROM (SELECT * FROM tbl_employee GROUP BY emp_name) AS t1;



-- eq_ref测试 start
DROP INDEX idx_dept_No On tbl_department;
ALTER TABLE tbl_department ADD UNIQUE INDEX idx_dept_No(dept_no);

DROP INDEX idx_emp_deptNo On tbl_employee;
ALTER TABLE tbl_employee ADD INDEX idx_emp_deptNo(dept_no);

SHOW INDEX FROM tbl_employee;
SHOW INDEX FROM tbl_department;

-- 注：WHERE 或 OR 中的条件判断涉及的表无先后顺序之别。如（WHERE tbD.dept_no=tbE.dept_no和WHERE tbE.dept_no=tbD.dept_no执行效果是一样的）
EXPLAIN SELECT * FROM tbl_employee as tbE, tbl_department as tbD WHERE tbD.dept_no=tbE.dept_no;
EXPLAIN SELECT * FROM tbl_department as tbD, tbl_employee as tbE WHERE tbD.dept_no=tbE.dept_no;
EXPLAIN SELECT * FROM tbl_employee as tbE LEFT JOIN tbl_department as tbD ON tbE.dept_no=tbD.dept_no;
EXPLAIN SELECT * FROM tbl_department tbD LEFT JOIN tbl_employee as tbE ON tbD.dept_no=tbE.dept_no;
-- eq_ref测试 end



-- group by、order by测试 start
注：
  在MySQL8.0版本前是存在Group by隐式排序的！ 就是说在我们使用分组（Group by）时，如：select * from T group by appName; 会默认在分组后按照appName正序排序，相当于select * from T group by appName order by appName;，倒排同理：select * from T group by appName desc; 可见，MySQL在8.0版本前的分组查询中，偷偷加上了排序操作。

-- type=ALL, key=Null, extra=Using temporary; Using filesort
EXPLAIN SELECT * FROM tbl_employee GROUP BY dept_no;
-- type=index, key=idx_emp_name, extra=Null
EXPLAIN SELECT * FROM tbl_employee GROUP BY emp_name;
-- type=ALL, key=null, extra=Using filesort
EXPLAIN SELECT * FROM tbl_employee ORDER BY dept_no;
-- type=ALL, key=null, extra=Using filesort
EXPLAIN SELECT * FROM tbl_employee ORDER BY emp_name;
-- type=index, key=idx_emp_name, extra=Using temporary; Using filesort
EXPLAIN SELECT * FROM tbl_employee GROUP BY emp_name ORDER BY emp_age;
-- type=index, key=idx_emp_name, extra=null
EXPLAIN SELECT * FROM tbl_employee GROUP BY emp_name ORDER BY emp_name;
-- group by、order by测试 end
