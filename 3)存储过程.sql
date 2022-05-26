******************** 存储过程 基本语法 start ********************

1) 创建存储过程
CREATE PROCEDURE 存储过程名([IN arg1 类型,IN arg2 类型,...])
BEGIN
  函数体...
END

2) 删除存储过程 *******************
DROP PROCEDURE 存储过程名;

3) 调用存储过程 ***********************
CALL 存储过程名([arg1,arg2,...]);

******************** 存储过程 基本语法 end ********************



DROP PROCEDURE IF EXISTS insert_dept;
DELIMITER $$
-- 向部门表(tbl_department)批量插入数据
CREATE PROCEDURE insert_dept(IN begin_num INT(10),IN loop_count INT(10))
BEGIN
 DECLARE i INT DEFAULT 0;
 SET autocommit=0;
 REPEAT
	SET i = i + 1;
	INSERT INTO tbl_department(dept_no,dept_name) VALUES((begin_num+i),CONCAT("部门",i));
 UNTIL i = loop_count END REPEAT;
 COMMIT;
END $$
DELIMITER ;

CALL insert_dept(100,10);




DROP PROCEDURE IF EXISTS insert_emp;
DELIMITER $$
-- 向员工表(tbl_employee)批量插入数据
CREATE PROCEDURE insert_emp(IN begin_num INT(10),IN loop_count INT(10))
BEGIN
 DECLARE i INT DEFAULT 0;
 SET autocommit=0;
 REPEAT
	SET i = i + 1;
	INSERT INTO tbl_employee(emp_no,emp_name,emp_age,emp_post,dept_no) VALUES((begin_num+i),rand_str(6),rand_num(20,30),rand_post(),rand_num(100,10));
 UNTIL i = loop_count END REPEAT;
 COMMIT;
END $$
DELIMITER ;

CALL insert_emp(1000,10000);





DROP PROCEDURE IF EXISTS dropIndex;
DELIMITER $$
-- 创建存储过程，判断索引是否存在，存在则删除
CREATE PROCEDURE dropIndex(IN databaseName VARCHAR(30),IN tableName VARCHAR(30),IN indexName VARCHAR(30))
proc:BEGIN
 DECLARE str VARCHAR(512) DEFAULT NULL;
 DECLARE cnt INT DEFAULT 0;
 SET @str = CONCAT("DROP INDEX ",indexName," ON ",databaseName,".",tableName);
 
 SELECT COUNT(1) INTO cnt FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = databaseName AND TABLE_NAME = tableName AND INDEX_NAME = indexName;
 
 IF cnt>0 THEN
   PREPARE stmt FROM @str;
	 EXECUTE stmt;
 END IF;
 LEAVE proc;
END $$
DELIMITER ;

