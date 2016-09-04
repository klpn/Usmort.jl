-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Värd: localhost
-- Tid vid skapande: 04 sep 2016 kl 07:19
-- Serverversion: 10.1.16-MariaDB
-- PHP-version: 7.0.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databas: `Usmort`
--
CREATE DATABASE IF NOT EXISTS `Usmort` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `Usmort`;

-- --------------------------------------------------------

--
-- Tabellstruktur `Usdeaths`
--

CREATE TABLE `Usdeaths` (
  `Resstatus` tinyint(1) NOT NULL,
  `Edu89` tinyint(2) NOT NULL,
  `Edu03` tinyint(1) DEFAULT NULL,
  `Edurep` tinyint(1) NOT NULL,
  `Dmon` tinyint(2) NOT NULL,
  `Sex` tinytext NOT NULL,
  `Agetype` tinyint(1) NOT NULL,
  `Age` smallint(3) NOT NULL,
  `Agesubst` tinyint(1) DEFAULT NULL,
  `AgeRe52` tinyint(2) NOT NULL,
  `AgeRe27` tinyint(2) NOT NULL,
  `AgeRe12` tinyint(2) NOT NULL,
  `InfAgeRe22` tinyint(2) DEFAULT NULL,
  `Dplace` tinyint(1) NOT NULL,
  `Mart` tinytext NOT NULL,
  `Dweek` tinyint(1) NOT NULL,
  `Datayear` year(4) NOT NULL,
  `Injwork` tinytext NOT NULL,
  `Dmanner` tinyint(1) DEFAULT NULL,
  `Disp` tinytext NOT NULL,
  `Autopsy` tinytext NOT NULL,
  `Actcode` tinyint(1) DEFAULT NULL,
  `Injplace` tinyint(1) DEFAULT NULL,
  `UcIcd` tinytext NOT NULL,
  `UcRe358` tinyint(3) NOT NULL,
  `UcRe113` tinyint(3) NOT NULL,
  `UcReInf130` tinyint(3) NOT NULL,
  `UcRe39` tinyint(2) NOT NULL,
  `EntNr` tinyint(2) NOT NULL,
  `Ent1` tinytext NOT NULL,
  `Ent2` tinytext,
  `Ent3` tinytext,
  `Ent4` tinytext,
  `Ent5` tinytext,
  `Ent6` tinytext,
  `Ent7` tinytext,
  `Ent8` tinytext,
  `Ent9` tinytext,
  `Ent10` tinytext,
  `Ent11` tinytext,
  `Ent12` tinytext,
  `Ent13` tinytext,
  `Ent14` tinytext,
  `Ent15` tinytext,
  `Ent16` tinytext,
  `Ent17` tinytext,
  `Ent18` tinytext,
  `Ent19` tinytext,
  `Ent20` tinytext,
  `RecNr` tinyint(2) NOT NULL,
  `Rec1` tinytext NOT NULL,
  `Rec2` tinytext,
  `Rec3` tinytext,
  `Rec4` tinytext,
  `Rec5` tinytext,
  `Rec6` tinytext,
  `Rec7` tinytext,
  `Rec8` tinytext,
  `Rec9` tinytext,
  `Rec10` tinytext,
  `Rec11` tinytext,
  `Rec12` tinytext,
  `Rec13` tinytext,
  `Rec14` tinytext,
  `Rec15` tinytext,
  `Rec16` tinytext,
  `Rec17` tinytext,
  `Rec18` tinytext,
  `Rec19` tinytext,
  `Rec20` tinytext,
  `Race` tinyint(2) NOT NULL,
  `Bridged` tinyint(1) DEFAULT NULL,
  `Impute` tinyint(1) DEFAULT NULL,
  `RaceRe3` tinyint(1) NOT NULL,
  `RaceRe5` tinyint(1) NOT NULL,
  `Hisp` smallint(3) NOT NULL,
  `HispRaceRe` tinyint(1) NOT NULL,
  `ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Index för dumpade tabeller
--

--
-- Index för tabell `Usdeaths`
--
ALTER TABLE `Usdeaths`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT för dumpade tabeller
--

--
-- AUTO_INCREMENT för tabell `Usdeaths`
--
ALTER TABLE `Usdeaths`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10205673;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

CREATE USER usmuser IDENTIFIED BY 'usmort';
GRANT SELECT ON Usmort.* TO usmuser;
