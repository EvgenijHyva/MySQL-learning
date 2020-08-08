/* 4. (по желанию) Ознакомьтесь более подробно с документацией утилиты 
 * mysqldump. Создайте дамп единственной таблицы help_keyword базы 
 * данных mysql. Причем добейтесь того, чтобы дамп содержал только 
 * первые 100 строк таблицы. */
mysqldump -u root -p --where="true limit 100" mysql --tables help_keyword > help_dump_100.sql
