-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: birdstack_development
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` text COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `occurred_at` datetime NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `index_activities_on_type` (`type`),
  KEY `index_activities_on_occurred_at` (`occurred_at`),
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `adm1s`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `adm1s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_adm1s_on_cc` (`cc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `adm2s`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `adm2s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `cc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `latitude` decimal(9,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_adm2s_on_adm1_and_cc` (`adm1`,`cc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alternate_names`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alternate_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `species_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `search_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `species_id` (`species_id`),
  CONSTRAINT `alternate_names_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `alternate_names_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `changes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `change_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `changes_species`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `changes_species` (
  `change_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  KEY `index_changes_species_on_change_id` (`change_id`),
  KEY `index_changes_species_on_species_id` (`species_id`),
  CONSTRAINT `changes_species_ibfk_1` FOREIGN KEY (`change_id`) REFERENCES `changes` (`id`),
  CONSTRAINT `changes_species_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comment_collections`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `post_count` int(11) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `posted_by` int(11) DEFAULT NULL,
  `last_post_id` int(11) DEFAULT NULL,
  `private` tinyint(1) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `posted_by` (`posted_by`),
  KEY `last_post_id` (`last_post_id`),
  CONSTRAINT `comment_collections_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `comment_collections_ibfk_2` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`),
  CONSTRAINT `comment_collections_ibfk_3` FOREIGN KEY (`last_post_id`) REFERENCES `comments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comment_collections_forums`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_collections_forums` (
  `forum_id` int(11) NOT NULL,
  `comment_collection_id` int(11) NOT NULL,
  KEY `forum_id` (`forum_id`),
  KEY `comment_collection_id` (`comment_collection_id`),
  CONSTRAINT `comment_collections_forums_ibfk_1` FOREIGN KEY (`forum_id`) REFERENCES `forums` (`id`),
  CONSTRAINT `comment_collections_forums_ibfk_2` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comment` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `comment_collection_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_user_id` (`user_id`),
  KEY `index_comments_on_created_at` (`created_at`),
  KEY `index_comments_on_user_id_and_created_at` (`user_id`,`created_at`),
  KEY `comment_collection_id` (`comment_collection_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversations_users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversations_users` (
  `user_id` int(11) NOT NULL,
  `conversation_id` int(11) NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `conversations_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `conversations_users_ibfk_2` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country_codes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_country_codes_on_cc` (`cc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delayed_jobs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` text COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ebird_exports`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ebird_exports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `families`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `families` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_order` int(11) DEFAULT NULL,
  `order_id` int(11) NOT NULL,
  `english_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `latin_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `english_name_search_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `genus_count` int(11) DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `sort_after_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `sort_after_id` (`sort_after_id`),
  CONSTRAINT `families_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `families_ibfk_2` FOREIGN KEY (`sort_after_id`) REFERENCES `families` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `forums`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `thread_count` int(11) DEFAULT NULL,
  `post_count` int(11) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `posted_by` int(11) DEFAULT NULL,
  `last_post_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_forums_on_url` (`url`),
  KEY `index_forums_on_sort_order` (`sort_order`),
  KEY `posted_by` (`posted_by`),
  KEY `last_post_id` (`last_post_id`),
  CONSTRAINT `forums_ibfk_1` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`),
  CONSTRAINT `forums_ibfk_2` FOREIGN KEY (`last_post_id`) REFERENCES `comments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `friend_relationships`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `friend_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `friend_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `friend_id` (`friend_id`),
  CONSTRAINT `friend_relationships_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friend_relationships_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `friend_requests`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `friend_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `potential_friend_id` int(11) NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `potential_friend_id` (`potential_friend_id`),
  CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`potential_friend_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genera`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genera` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_order` int(11) DEFAULT NULL,
  `family_id` int(11) NOT NULL,
  `latin_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `species_count` int(11) DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `sort_after_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `family_id` (`family_id`),
  KEY `sort_after_id` (`sort_after_id`),
  CONSTRAINT `genera_ibfk_1` FOREIGN KEY (`family_id`) REFERENCES `families` (`id`),
  CONSTRAINT `genera_ibfk_2` FOREIGN KEY (`sort_after_id`) REFERENCES `genera` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ignored_notifications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ignored_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `notification_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `ignored_notifications_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`),
  CONSTRAINT `ignored_notifications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` decimal(9,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `cc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm2` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_cc` (`cc`),
  KEY `index_locations_on_adm1_and_cc` (`adm1`,`cc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message_references`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `read` tinyint(1) DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `message_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `message_id` (`message_id`),
  CONSTRAINT `message_references_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `message_references_ibfk_2` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `conversation_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `species_id` int(11) NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `species_id` (`species_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications_species`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications_species` (
  `notification_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `species_id` (`species_id`),
  CONSTRAINT `notifications_species_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`),
  CONSTRAINT `notifications_species_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_order` int(11) DEFAULT NULL,
  `latin_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `family_count` int(11) DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `sort_after_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_orders_on_latin_name` (`latin_name`),
  KEY `sort_after_id` (`sort_after_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`sort_after_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_recovery_codes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_recovery_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_password_recovery_codes_on_code` (`code`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `password_recovery_codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pending_import_items`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_import_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `english_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `location_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_year` int(11) DEFAULT NULL,
  `date_month` int(11) DEFAULT NULL,
  `date_day` int(11) DEFAULT NULL,
  `trip_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `time_hour` int(11) DEFAULT NULL,
  `time_minute` int(11) DEFAULT NULL,
  `species_count` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `juvenile_male` int(11) DEFAULT NULL,
  `juvenile_female` int(11) DEFAULT NULL,
  `juvenile_unknown` int(11) DEFAULT NULL,
  `immature_male` int(11) DEFAULT NULL,
  `immature_female` int(11) DEFAULT NULL,
  `immature_unknown` int(11) DEFAULT NULL,
  `adult_male` int(11) DEFAULT NULL,
  `adult_female` int(11) DEFAULT NULL,
  `adult_unknown` int(11) DEFAULT NULL,
  `unknown_male` int(11) DEFAULT NULL,
  `unknown_female` int(11) DEFAULT NULL,
  `unknown_unknown` int(11) DEFAULT NULL,
  `line` int(11) DEFAULT NULL,
  `pending_import_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `validated` tinyint(1) DEFAULT NULL,
  `link` text COLLATE utf8_unicode_ci,
  `tag_list` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `pending_import_id` (`pending_import_id`),
  CONSTRAINT `pending_import_items_ibfk_1` FOREIGN KEY (`pending_import_id`) REFERENCES `pending_imports` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pending_imports`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ebird_exclude` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `pending_imports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `primary_adm1s`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `primary_adm1s` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `adm1_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_primary_adm1s_on_cc_and_adm1` (`cc`,`adm1`),
  KEY `adm1_id` (`adm1_id`),
  CONSTRAINT `primary_adm1s_ibfk_1` FOREIGN KEY (`adm1_id`) REFERENCES `adm1s` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regions_species`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regions_species` (
  `region_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  KEY `index_regions_species_on_region_id` (`region_id`),
  KEY `index_regions_species_on_species_id` (`species_id`),
  CONSTRAINT `regions_species_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  CONSTRAINT `regions_species_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `remember_me_cookies`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `remember_me_cookies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_remember_me_cookies_on_token` (`token`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `remember_me_cookies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `saved_searches`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `search` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `temp` tinyint(1) NOT NULL DEFAULT '1',
  `private` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sighting_photos`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sighting_photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_file_size` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_updated_at` datetime NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `sighting_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `processing` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  `private` tinyint(1) NOT NULL DEFAULT '1',
  `comment_collection_id` int(11) NOT NULL,
  `license` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `sighting_photo_activity_id` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `species_id` int(11) NOT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `user_location_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sighting_id` (`sighting_id`),
  KEY `user_id` (`user_id`),
  KEY `comment_collection_id` (`comment_collection_id`),
  KEY `sighting_photo_activity_id` (`sighting_photo_activity_id`),
  KEY `trip_id` (`trip_id`),
  KEY `user_location_id` (`user_location_id`),
  CONSTRAINT `sighting_photos_ibfk_1` FOREIGN KEY (`sighting_id`) REFERENCES `sightings` (`id`),
  CONSTRAINT `sighting_photos_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `sighting_photos_ibfk_3` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`),
  CONSTRAINT `sighting_photos_ibfk_4` FOREIGN KEY (`sighting_photo_activity_id`) REFERENCES `activities` (`id`),
  CONSTRAINT `sighting_photos_ibfk_5` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`),
  CONSTRAINT `sighting_photos_ibfk_6` FOREIGN KEY (`user_location_id`) REFERENCES `user_locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sightings`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sightings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_location_id` int(11) DEFAULT NULL,
  `date_day` int(11) DEFAULT NULL,
  `date_month` int(11) DEFAULT NULL,
  `date_year` int(11) DEFAULT NULL,
  `trip_id` int(11) DEFAULT NULL,
  `species_count` int(11) DEFAULT NULL,
  `juvenile_male` int(11) DEFAULT NULL,
  `juvenile_female` int(11) DEFAULT NULL,
  `juvenile_unknown` int(11) DEFAULT NULL,
  `immature_male` int(11) DEFAULT NULL,
  `immature_female` int(11) DEFAULT NULL,
  `immature_unknown` int(11) DEFAULT NULL,
  `adult_male` int(11) DEFAULT NULL,
  `adult_female` int(11) DEFAULT NULL,
  `adult_unknown` int(11) DEFAULT NULL,
  `unknown_male` int(11) DEFAULT NULL,
  `unknown_female` int(11) DEFAULT NULL,
  `unknown_unknown` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `time_hour` int(11) DEFAULT NULL,
  `time_minute` int(11) DEFAULT NULL,
  `comment_collection_id` int(11) DEFAULT NULL,
  `private` tinyint(1) DEFAULT '0',
  `ebird` int(11) DEFAULT NULL,
  `ebird_exclude` tinyint(1) NOT NULL DEFAULT '0',
  `cached_tag_list` text COLLATE utf8_unicode_ci,
  `link` text COLLATE utf8_unicode_ci,
  `sighting_activity_id` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sightings_on_comment_collection_id` (`comment_collection_id`),
  KEY `index_sightings_on_user_id` (`user_id`),
  KEY `species_id` (`species_id`),
  KEY `user_location_id` (`user_location_id`),
  KEY `trip_id` (`trip_id`),
  KEY `index_sightings_on_private` (`private`),
  KEY `index_sightings_on_ebird` (`ebird`),
  KEY `sighting_activity_id` (`sighting_activity_id`),
  CONSTRAINT `sightings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `sightings_ibfk_2` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `sightings_ibfk_3` FOREIGN KEY (`user_location_id`) REFERENCES `user_locations` (`id`),
  CONSTRAINT `sightings_ibfk_4` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`),
  CONSTRAINT `sightings_ibfk_5` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`),
  CONSTRAINT `sightings_ibfk_6` FOREIGN KEY (`ebird`) REFERENCES `ebird_exports` (`id`),
  CONSTRAINT `sightings_ibfk_7` FOREIGN KEY (`sighting_activity_id`) REFERENCES `activities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_order` int(11) DEFAULT NULL,
  `genus_id` int(11) NOT NULL,
  `english_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `latin_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `breeding_subregions` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nonbreeding_regions` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `change_id` int(11) DEFAULT NULL,
  `english_name_search_version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `binomial_name_search_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_after_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_species_on_change_id` (`change_id`),
  KEY `genus_id` (`genus_id`),
  KEY `change_id` (`change_id`),
  KEY `index_species_on_english_name_search_version` (`english_name_search_version`),
  KEY `sort_after_id` (`sort_after_id`),
  CONSTRAINT `species_ibfk_1` FOREIGN KEY (`genus_id`) REFERENCES `genera` (`id`),
  CONSTRAINT `species_ibfk_2` FOREIGN KEY (`change_id`) REFERENCES `changes` (`id`),
  CONSTRAINT `species_ibfk_3` FOREIGN KEY (`sort_after_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taggings`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type` (`taggable_id`,`taggable_type`),
  CONSTRAINT `taggings_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trip_photos`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trip_photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_file_size` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_updated_at` datetime NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `trip_id` int(11) NOT NULL,
  `processing` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  `private` tinyint(1) NOT NULL DEFAULT '1',
  `comment_collection_id` int(11) NOT NULL,
  `license` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `trip_photo_activity_id` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `trip_photo_activity_id` (`trip_photo_activity_id`),
  KEY `trip_id` (`trip_id`),
  KEY `user_id` (`user_id`),
  KEY `comment_collection_id` (`comment_collection_id`),
  CONSTRAINT `trip_photos_ibfk_1` FOREIGN KEY (`trip_photo_activity_id`) REFERENCES `activities` (`id`),
  CONSTRAINT `trip_photos_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`),
  CONSTRAINT `trip_photos_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `trip_photos_ibfk_4` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trips`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `parent_id` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_hour_start` int(11) DEFAULT NULL,
  `time_minute_start` int(11) DEFAULT NULL,
  `protocol` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'casual',
  `number_observers` int(11) DEFAULT NULL,
  `duration_hours` int(11) DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `distance_traveled_mi` float DEFAULT NULL,
  `distance_traveled_km` float DEFAULT NULL,
  `area_covered_acres` float DEFAULT NULL,
  `area_covered_sqmi` float DEFAULT NULL,
  `area_covered_sqkm` float DEFAULT NULL,
  `date_day_start` int(11) DEFAULT NULL,
  `date_month_start` int(11) DEFAULT NULL,
  `date_year_start` int(11) DEFAULT NULL,
  `all_observations_reported` tinyint(1) NOT NULL DEFAULT '0',
  `date_day_end` int(11) DEFAULT NULL,
  `date_month_end` int(11) DEFAULT NULL,
  `date_year_end` int(11) DEFAULT NULL,
  `comment_collection_id` int(11) DEFAULT NULL,
  `private` tinyint(1) DEFAULT '0',
  `cached_tag_list` text COLLATE utf8_unicode_ci,
  `link` text COLLATE utf8_unicode_ci,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_trips_on_comment_collection_id` (`comment_collection_id`),
  KEY `index_trips_on_user_id` (`user_id`),
  KEY `index_trips_on_name` (`name`),
  KEY `index_trips_on_private` (`private`),
  CONSTRAINT `trips_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `trips_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `trips_ibfk_4` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_location_photos`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_location_photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_file_size` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `photo_updated_at` datetime NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `user_location_id` int(11) NOT NULL,
  `processing` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  `private` tinyint(1) NOT NULL,
  `comment_collection_id` int(11) NOT NULL,
  `license` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_location_photo_activity_id` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_location_photo_activity_id` (`user_location_photo_activity_id`),
  KEY `user_location_id` (`user_location_id`),
  KEY `user_id` (`user_id`),
  KEY `comment_collection_id` (`comment_collection_id`),
  CONSTRAINT `user_location_photos_ibfk_1` FOREIGN KEY (`user_location_photo_activity_id`) REFERENCES `activities` (`id`),
  CONSTRAINT `user_location_photos_ibfk_2` FOREIGN KEY (`user_location_id`) REFERENCES `user_locations` (`id`),
  CONSTRAINT `user_location_photos_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_location_photos_ibfk_4` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_locations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `adm1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `adm2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `latitude` decimal(17,15) DEFAULT NULL,
  `longitude` decimal(18,15) DEFAULT NULL,
  `zoom` int(11) DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `comment_collection_id` int(11) DEFAULT NULL,
  `ecoregion` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `elevation_ft` float DEFAULT NULL,
  `elevation_m` float DEFAULT NULL,
  `private` int(11) DEFAULT '0',
  `cached_tag_list` text COLLATE utf8_unicode_ci,
  `link` text COLLATE utf8_unicode_ci,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_locations_on_comment_collection_id` (`comment_collection_id`),
  KEY `index_user_locations_on_user_id` (`user_id`),
  KEY `index_user_locations_on_name` (`name`),
  KEY `index_user_locations_on_private` (`private`),
  CONSTRAINT `user_locations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_locations_ibfk_2` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `crypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `salt` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `activation_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'invalid',
  `activated_at` datetime DEFAULT NULL,
  `gender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` text COLLATE utf8_unicode_ci,
  `bio` text COLLATE utf8_unicode_ci,
  `comment_collection_id` int(11) DEFAULT NULL,
  `signature` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_trip_private` tinyint(1) DEFAULT NULL,
  `default_user_location_private` int(11) DEFAULT NULL,
  `default_observation_private` tinyint(1) DEFAULT NULL,
  `public_observations` int(11) DEFAULT NULL,
  `pending_taxonomy_changes` tinyint(1) NOT NULL DEFAULT '0',
  `cc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cached_tag_list` text COLLATE utf8_unicode_ci,
  `notify_profile_comment` tinyint(1) NOT NULL DEFAULT '1',
  `notify_forum_comment` tinyint(1) NOT NULL DEFAULT '1',
  `notify_sighting_comment` tinyint(1) NOT NULL DEFAULT '1',
  `notify_user_location_comment` tinyint(1) NOT NULL DEFAULT '1',
  `notify_trip_comment` tinyint(1) NOT NULL DEFAULT '1',
  `notify_taxonomy_changes` tinyint(1) NOT NULL DEFAULT '1',
  `notify_newsletter` tinyint(1) NOT NULL DEFAULT '1',
  `notify_message` tinyint(1) NOT NULL DEFAULT '1',
  `unread_messages` int(11) NOT NULL DEFAULT '0',
  `notify_friend_request` tinyint(1) NOT NULL DEFAULT '1',
  `pending_friend_requests` int(11) NOT NULL DEFAULT '0',
  `time_zone` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'UTC',
  `time_24_hr` tinyint(1) NOT NULL DEFAULT '1',
  `time_day_first` tinyint(1) NOT NULL DEFAULT '1',
  `login_lcase` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `supporting_member` tinyint(1) NOT NULL DEFAULT '0',
  `profile_pic_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile_pic_file_size` int(11) DEFAULT NULL,
  `profile_pic_updated_at` datetime DEFAULT NULL,
  `profile_pic_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `blocked` tinyint(1) NOT NULL DEFAULT '0',
  `num_photos` int(11) NOT NULL DEFAULT '0',
  `notify_photo_comment` tinyint(1) NOT NULL DEFAULT '1',
  `default_photo_license` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'all-rights-reserved',
  `notify_membership` tinyint(1) NOT NULL DEFAULT '1',
  `export_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `export_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `export_file_size` int(11) DEFAULT NULL,
  `export_updated_at` datetime DEFAULT NULL,
  `export_started` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_activation_code` (`activation_code`),
  UNIQUE KEY `index_users_on_login` (`login`),
  UNIQUE KEY `login_lcase_unique` (`login_lcase`),
  KEY `comment_collection_id` (`comment_collection_id`),
  KEY `index_users_on_cc` (`cc`),
  KEY `index_users_on_location` (`location`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`comment_collection_id`) REFERENCES `comment_collections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `users_login_insert` BEFORE INSERT ON `users` FOR EACH ROW SET NEW.login_lcase = LOWER(NEW.login) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `users_login_update` BEFORE UPDATE ON `users` FOR EACH ROW SET NEW.login_lcase = LOWER(NEW.login) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-02-25 21:48:21
