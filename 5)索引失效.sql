
******************** 索引失效情况 start ********************
1）违背最左前缀法则
2）在索引字段做任何操作(计算，函数，(自动/手动)类型转换)
3）复合所应的中间字段使用了范围查询，将会导致复合索引中，从范围条件开始的右边的索引失效
4）使用不等于(!=或者<>)
5）使用is null,is not null
6）like以通配符开头('%abc..')
7）使用字符串做条件时，字符串不加引号
8）使用or做连接
******************** 索引失效情况 end ********************


-- 为tbl_employee(emp_no)字段添加唯一性约束(为字段添加唯一性约束，即为该字段创建索引,默认索引名为字段名)；
-- 未添加唯一性约束情况下，(EXPLAIN SELECT * FROM tbl_employee WHERE emp_no = 1001;)中, type=ref
-- 添加唯一性约束情况下，(EXPLAIN SELECT * FROM tbl_employee WHERE emp_no = 1001;)中, type=const
ALTER TABLE tbl_employee ADD UNIQUE(emp_no);
-- 删除唯一性约束
DROP INDEX emp_no ON tbl_employee;




CALL dropIndex("study_mysql","tbl_employee","idx_emp_nameAgeDno");

CREATE INDEX idx_emp_nameAgeDno ON tbl_employee(emp_name,emp_age,dept_no);
SHOW INDEX FROM tbl_employee;

-- 查询有多少不相同的名字
SELECT COUNT(1) FROM (SELECT emp_name FROM tbl_employee GROUP BY emp_name) AS te;




-- 情形1：违背最左前缀法则
-- type=const, key=PRIMARY, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE id = 1001;
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP";
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const,const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" AND emp_age = 29;
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const,const,const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" AND emp_age = 39 AND dept_no = 100 ;
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_age = 39;
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE dept_no = 100;
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_age = 39 AND dept_no = 100;



-- 情形2：在索引字段做任何操作(计算，函数，(自动/手动)类型转换)
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP";
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=Using index
EXPLAIN SELECT id,CONCAT(emp_name,"+++") FROM tbl_employee WHERE emp_name="ZWLRXP";
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT id,CONCAT(emp_name,"+++"),emp_post FROM tbl_employee WHERE emp_name="ZWLRXP";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE LEFT(emp_name,6) = "ZWLRXP";



-- 情形3：复合所应的中间字段使用了范围查询，将会导致复合索引中，从范围条件开始的右边的索引失效
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age>25;
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age>25 AND dept_no = 100;




-- 情形4：使用不等于(!=或者<>)
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name != "ZWLRXP";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name <> "ZWLRXP";




-- 情形5：使用is null,is not null
-- type=null, extra=Impossible WHERE
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name is null;
-- type=all, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name is not null;



-- 情形6：like以通配符开头('%abc..')
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "%ZWL";
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "ZWL%";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "%ZWL%";
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "ZWL";
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using where;Using index
EXPLAIN SELECT id,emp_name,dept_no FROM tbl_employee WHERE emp_name LIKE "ZWLRXP";
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT emp_no FROM tbl_employee WHERE emp_name LIKE "ZWLRXP";




-- 情形7：使用数值型字符串做条件时，字符串不加引号
-- 报错 1054 - Unknown column 'ZWLRXP' in 'where clause'
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name=ZWLRXP;
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = 2000;
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "2000";




-- 情形8：使用or做连接
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" OR emp_name = "IMEZJV";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" OR emp_age = 25;
-- type=index_merge, key=idx_employee_nameAgeDno,PRIMARY, ref=null, extra=Using sort_union(idx_employee_nameAgeDno,PRIMARY);Using where
EXPLAIN SELECT * FROM tbl_employee WHERE id = 1001 OR emp_name = "IMEZJV";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE id = 1001 OR emp_age = "IMEZJV";


