/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotes` (
  `author` varchar(80) DEFAULT NULL,
  `text` varchar(512) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `quotes` VALUES ('Pippo','I like become super-goofy. Yuk'),('Topolino','The detective is here!');
