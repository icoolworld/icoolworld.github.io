#�������ݵ����ݱ���Loading Data into a Table

ʹ��LOAD DATA����ʵ����table����������insert���ݹ���

You could create a text file pet.txt containing one record per line, with values separated by tabs, and given in the order in which the columns were listed in the CREATE TABLE statement. For missing values (such as unknown sexes or death dates for animals that are still living), you can use NULL values. To represent these in your text file, use \N (backslash, capital-N). For example, the record for Whistler the bird would look like this (where the whitespace between values is a single tab character):

��������ݣ��ֶ�ֵ֮��ʹ��tab���ֿ�����������ʹ�÷��п�
Whistler        Gwen    bird    \N      1997-12-09      \N


To load the text file pet.txt into the pet table, use this statement:

```
mysql> LOAD DATA LOCAL INFILE '/path/pet.txt' INTO TABLE pet;
```

If you created the file on Windows with an editor that uses \r\n as a line terminator, you should use this statement instead:
�����windowsϵͳ��ʹ��\r\n���з�
```
mysql> LOAD DATA LOCAL INFILE '/path/pet.txt' INTO TABLE pet
    -> LINES TERMINATED BY '\r\n';
```
	

http://dev.mysql.com/doc/refman/5.7/en/loading-tables.html