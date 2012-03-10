/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `links` (
  `href` varchar(512) DEFAULT NULL,
  `tags` varchar(512) DEFAULT NULL,
  `title` varchar(512) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `links` VALUES ('http://www.google.it','engine,search','Google');
