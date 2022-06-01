******************** 索引失效情况 start ********************
1）违背最左前缀法则（即，WHERE从左边开始比较的字段顺序和索引创建时的字段顺序不一致）。
2）对WHERE判断条件中涉及的索引字段做任何操作（计算，函数，(自动/手动)类型转换）。
3）WHERE判断条件中涉及复合索引时，对复合索引的中间字段使用了范围查询，导致复合索引从范围条件开始（含范围条件开始涉及的索引字段）的右侧索引字段失效。
4）WHERE判断条件中，使用了不等于比较操作(!=或者<>)，导致从不等于判断条件开始（含开始判断涉及的索引字段）的右侧索引字段失效。
5）WHERE判断条件中,对索引字段使用了is null、is not null，导致从is null、is not null判断条件开始（含开始判断涉及的索引字段）的右侧索引字段失效。(注：使用is null，is not null 也存在例外)
6）WHERE判断条件中，使用了like，且like中的内容匹配模式以通配符开头(如，'%abc')。
7）索引字段为数值字符字段时，WHERE判断中直接使用数值（数值两侧不加引号）当做条件。
8）WHERE条件判断中使用了OR，且OR连接涉及的条件字段不是一个索引中的最左前缀字段。
******************** 索引失效情况 end ********************



CALL dropIndex("study_mysql","tbl_employee","idx_emp_NameAgeDno");
CREATE INDEX idx_emp_NameAgeDno ON tbl_employee(emp_name,emp_age,dept_no);
SHOW INDEX FROM tbl_employee;

-- 查询有多少不相同的名字
EXPLAIN SELECT COUNT(1) FROM (SELECT emp_name FROM tbl_employee GROUP BY emp_name) AS tbE;


-- 情形1：违背最左前缀法则
-- type=const, key=PRIMARY, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE id = 1001;
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP";
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const,const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" AND emp_age = 29;
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" AND dept_no = 100;
-- type=ref, key=idx_idx_employee_nameAgeDno, ref=const,const,const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" AND emp_age = 39 AND dept_no = 100 ;
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_age = 39;
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_age = 39 AND dept_no = 100;


-- 情形2：对在WHERE判断条件中涉及的索引字段做任何操作(计算，函数，(自动/手动)类型转换等...)。
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=Using index
EXPLAIN SELECT id,CONCAT(emp_name,"+++") FROM tbl_employee WHERE emp_name="ZWLRXP";
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE LEFT(emp_name,6) = "ZWLRXP";


-- 情形3：WHERE判断条件中涉及复合索引时，对复合索引的中间字段使用了范围查询，导致复合索引从范围条件开始的右侧索引失效。
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age>25;
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age<25 AND dept_no = 100;


-- 情形4：WHERE判断条件中使用了不等于比较操作(!=或者<>)，导致从不等于判断条件开始（含）的右侧索引失效。
-- type=all, key=idx_employee_nameAgeDno, ref=null, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name <> "ZWLRXP";
-- type=range, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age!=25;


-- 情形5：WHERE判断条件中,对索引字段使用了is null、is not null，导致从is null、is not null判断条件开始（含开始判断涉及的索引字段）的右侧索引字段失效。
  (注：使用is null，is not null 也存在例外)
-- type=all, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name is not null;
-- type=ref, key=idx_emp_NameAgeDno, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name is null;
-- type=range, key=idx_emp_NameAgeDno, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name="ZWLRXP" AND emp_age is not null AND dept_no=100;


-- 情形6：WHERE判断条件中，使用了like，且like中的内容匹配模式以通配符开头(如，'%abc')。
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "%ZWL";
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name LIKE "ZWL%";


-- 情形7：索引字段为数值字符字段时，WHERE判断中直接使用数值（数值两侧不加引号）当做条件。
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = 2000;
-- type=ref, key=idx_employee_nameAgeDno, ref=const, extra=null
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "2000";


-- 情形8：使用or做连接
-- type=all, extra=Using where
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" OR emp_age = 25;
-- type=range, key=idx_employee_nameAgeDno, ref=null, extra=Using index condition
EXPLAIN SELECT * FROM tbl_employee WHERE emp_name = "ZWLRXP" OR emp_name = "IMEZJV";
-- type=index_merge, key=idx_employee_nameAgeDno,PRIMARY, ref=null, extra=Using sort_union(idx_employee_nameAgeDno,PRIMARY);Using where
EXPLAIN SELECT * FROM tbl_employee WHERE id = 1001 OR emp_name = "IMEZJV";

