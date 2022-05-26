******************** 函数 基本语法 start ********************

1) 创建函数
CREATE FUNCTION 函数名([arg1 类型,arg2 类型,...])
RETURNS 返回类型
BEGIN
  函数体...
END

2) 删除函数
DROP FUNCTION 函数名;

3) 函数调用
函数名([arg1,arg2,...])

******************** 函数 基本语法 end ********************




DROP FUNCTION IF EXISTS rand_str;
DELIMITER $$
-- 返回指定长度随机字符串
CREATE FUNCTION rand_str(n INT)
RETURNS VARCHAR(255)
BEGIN
 DECLARE chars_str VARCHAR(100) DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 DECLARE return_str VARCHAR(255) DEFAULT '';
 DECLARE i INT DEFAULT 0;
 WHILE i < n DO
  SET return_str=CONCAT(return_str,SUBSTRING(chars_str,FLOOR(1+RAND()*26),1));
  SET i = i + 1;
 END WHILE;
 RETURN return_str;
END $$
DELIMITER ;

SELECT rand_str(6);




DROP FUNCTION IF EXISTS rand_num;
DELIMITER $$
-- 产生指定范围内的随机数值, [baseNum,(baseNum+rangeNum))
CREATE FUNCTION rand_num(baseNum INT,rangeNum INT)
RETURNS INT(11)
BEGIN
 DECLARE i INT DEFAULT 0;
 SET i = FLOOR(baseNum+RAND()*rangeNum);
 RETURN i;
END $$
DELIMITER ;

SELECT rand_num(100,10);




DROP FUNCTION IF EXISTS rand_post;
DELIMITER $$
-- 产生随机职位
CREATE FUNCTION rand_post()
RETURNS VARCHAR(10)
BEGIN
  DECLARE postList VARCHAR(100) DEFAULT "java开发工程师,前端开发工程师,软件测试工程师,系统分析师,系统架构师,技术经理,CTO,项目组长,项目经理,项目总监,产品设计师,产品经理,技术销售工程师,技术支持工程师,培训讲师";
	DECLARE i INT DEFAULT 0;
	DECLARE post VARCHAR(15);
	SET i = ROUND(RAND()*15+0.5);
	SET post = SUBSTRING_INDEX(SUBSTRING_INDEX(postList,",",i),",",-1);
	RETURN post;
END $$
DELIMITER ;

SELECT rand_post();



