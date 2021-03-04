CREATE TABLE `gb_banking` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `login` varchar(24) DEFAULT NULL,
  `password` varchar(24) DEFAULT NULL,
  `removecode` varchar(4) DEFAULT NULL,
  `balance` int(24) NOT NULL DEFAULT '0',
  `debitcard` varchar(24) DEFAULT NULL,
  `dc_pin` varchar(4) DEFAULT NULL,
  `isLogged` int(11) NOT NULL DEFAULT '0',
  `realOwner` varchar(50) DEFAULT NULL,
  `mainAccount` int(11) NOT NULL DEFAULT 0,
  `accountNumber` varchar(24) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `gb_banking`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `gb_banking`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
