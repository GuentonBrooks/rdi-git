000001231218**Free
000002231218// ********************************************************************
000003231218// *
000004231218// IBIS Management Associates B.V.
000005231218// *
000006231218// FILE NAME: ABAACCP1R.RPGLE
000007231218// *
000008231218// DESCRIPTION:
000009231218// ------------
000010231221// This Application is built as a service program for the integrated
000011231221// web services server which can be configured using the IBM Web
000012231221// Administration for i.
000016231218//
000017231221// This Specific service program is created to deliver user accounts
000018231221// on basis of the customerNumber that is delivered by the client.
000019231218// *
000031231218// ********************************************************************
000032231218// System       : ABA: Alchemy Banking Application
000033231221// Program      : ABAACCP1R: Account List Delivery Handler WebServices
000034231221// Created      : 21-12-2023
000035231218// Author       : Guenton Brooks
000036231221// Function     : Handle REST Api calls for Accountlists
000037231218//
000038231218// --------------------------------------------------------------------
000039231218// Modifications:
000040231218// Reason       :
000041231218// Solution     :
000042231218//
000043231218// --------------------------------------------------------------------
000044231218// ====================================================================
000045231218// Headers
000046231218// ====================================================================
000048231218CTL-OPT Copyright('(C)2023 IBIS Management Associates B.V., info@ibis-management.com');
000050231218CTL-OPT DatEdit(*YMD);
000051231218CTL-OPT BndDir('SPR');
000052231219CTL-OPT NoMain;
000053231218CTL-OPT PgmInfo(*PCML : *MODULE : *DCLCASE);
000054231218
000055231218
000056231218// ====================================================================
000057231218// Templates
000058231218// ====================================================================
000059231218DCL-DS accountFormat QUALIFIED TEMPLATE;
000060231218  accountNumber CHAR(17);
000061231220  currency CHAR(3);
000062231218  branch CHAR(5);
000063231218  status CHAR(3);
000064231218  accountTypeCode CHAR(3);
000065231218  accountTypeDesc CHAR(35);
000066231218  productType CHAR(3);
000068231218  customerNumber CHAR(12);
000069231218  customerShortName CHAR(20);
000070231218  customerName CHAR(35);
000071231218  address CHAR(35);
000072231218  city CHAR(35);
000073231218  countryCode CHAR(2);
000074231218  accountOfficer CHAR(35);
000075231218  ledgerBalance PACKED(17);
000076231218  availableBalance PACKED(17);
000077231218  reservedBalance PACKED(17);
000078231218  constCenter CHAR(5);
000079231218  employeeFlag CHAR(5);
000080231218  createdAt TIMESTAMP;
000081231218  deletedAt TIMESTAMP;
000082231218  hasAccountPostings IND;
000083231218  hasStatements IND;
000084231218  hasStandingOrders IND;
000085231218  isDeleted IND;
000086231218END-DS;
000087231218
000088231219
000089231218// ====================================================================
000090231218// Prototypes
000091231218// ====================================================================
000092231219DCL-PR GetAllAccounts;
000093231218  customerNumber CHAR(12) CONST;
000094231218  accountListLength INT(10);
000095231218  accountList LIKEDS(accountFormat) DIM(1000) OPTIONS(*varsize);
000096231218  httpStatus INT(10);
000097231218  httpHeaders CHAR(100) DIM(10);
000098231218END-PR;
000099231218
000137231218// --------------------------------------------------------------------
000138231218// *
000139231218// GetAllAccounts
000140231218//   Retreive all accounts that match the customerNumber.
000141231221//   Prepare all results in accountList
000142231221//   to be picked up by the WebServices.
000143231218// *
000144231221// Parameters:  customerNumber, accountListLength accountList, httpStatus, httpHeaders
000146231221// Globals:     -
000147231218// *
000148231221// Returns:     void
000149231218//---------------------------------------------------------------------
000150231218DCL-PROC GetAllAccounts EXPORT;
000151231218  DCL-PI *N;
000152231218    customerNumber CHAR(12) CONST;
000153231218    accountListLength INT(10);
000154231218    accountList LIKEDS(accountFormat) DIM(1000) OPTIONS(*varsize);
000155231218    httpStatus INT(10);
000156231218    httpHeaders CHAR(100) DIM(10);
000157231218  END-PI;
000158231218
000159231218  // Account List by Customer Number
000160231220  DCL-F SPRACC03L USAGE(*input) KEYED USROPN;
000161231218  DCL-DS accountDS LIKEREC(ACCR);
000162231219  DCL-S index INT(10) INZ(0);
000163231218
000164231218  // Make sure everything is empty
000165231218  CLEAR httpHeaders;
000166231218  CLEAR accountList;
000167231218  CLEAR accountDS;
000168231220
000169231220  // Open File if not open
000170231220  IF NOT %open(SPRACC03L);
000171231220    OPEN SPRACC03L;
000172231220  ENDIF;
000173231218
000178231218  // Position the file to the first record with the customerNumber
000179231218  SETLL customerNumber ACCR;
000181231218
000182231218  // Only operate on data if positioning was successful
000183231218  IF %equal;
000184231218    // Read the first equal record at the pointer
000185231218    READE customerNumber ACCR accountDS;
000186231218    IF (%ERROR);
000187231219      httpStatus = 404;
000188231218      return;
000189231218    ENDIF;
000190231218
000191231218    // Loop through all customerNumber matching account records
000192231218    // Populate the account List
000193231218    DOW NOT %eof;
000194231218      // Increment the list Length
000195231219      index += 1;
000196231218
000197231219      accountList(index).accountNumber = accountDS.ACCACCNUM; // AccountNumber
000199231220      accountList(index).currency = accountDS.ACCACCCCY; // Currency
000200231219      accountList(index).branch = accountDS.ACCACCBRH; // Branch
000201231219      accountList(index).status = accountDS.ACCACCSTS; // Status
000202231219      accountList(index).accountTypeCode = accountDS.ACCACCTYP; // AccountTypeCode
000203231219      accountList(index).accountTypeDesc = 'Under Development'; // AccountTypeDesc
000204231219      accountList(index).customerNumber = accountDS.ACCCUSNUM; // CustomerNumber
000205231219      accountList(index).customerSHortName = accountDS.ACCCUSSHN; // CustomerShortName
000206231219      accountList(index).customerName = accountDS.ACCCUSNAM; // CustomerName
000207231219      accountList(index).address = accountDS.ACCCUSADD; // Address
000208231219      accountList(index).city = accountDS.ACCCUSCTY; // City
000209231219      accountList(index).countryCode = accountDS.ACCCUSCOU; // CountryCode
000210231219      accountList(index).accountOfficer = accountDS.ACCACCOFC; // Account Officer
000211231219      accountList(index).ledgerBalance = accountDS.ACCLDGBAL; // Ledger Balance
000212231219      accountList(index).availableBalance = accountDS.ACCAVLBAL; // Available Balance
000213231219      accountList(index).reservedBalance = accountDS.ACCRSVBAL; // Reserved Balance
000214231219      accountList(index).availableBalance = accountDS.ACCAVLBAL; // Available Balance
000215231219      accountList(index).constCenter = accountDS.ACCCSTCNT; // Const Center
000216231219      accountList(index).employeeFlag = accountDS.ACCEMPFLG; // Employee Flag
000217231219      accountList(index).createdAt = accountDS.ACCCRTS; // Created Timestamp
000218231219      accountList(index).deletedAt = accountDS.ACCDLTS; // Deleted Timestamp
000219231221      accountList(index).hasAccountPostings = HasPostings(accountDS.ACCACCNUM);
000221231221      accountList(index).hasStatements = HasStatements(accountDS.ACCACCNUM);
000223231221      accountList(index).hasStandingOrders = HasStandingOrders(accountDS.ACCACCNUM);
000225231219      accountList(index).isDeleted = CheckIfDeleted(accountDS.ACCSTAT1:accountDS.ACCSTAT2);
000226231218
000255231218      // Repeat the Loop
000256231218      READE customerNumber ACCR accountDS;
000257231218      IF (%ERROR);
000258231219        httpStatus = 500;
000259231218        return;
000260231218      ENDIF;
000261231218    ENDDO;
000262231218
000272231219    accountListLength = index;
000273231218  ELSE;
000274231219    httpStatus = 404;
000275231218    RETURN;
000276231218  ENDIF;
000277231218
000278231219  httpStatus = 200;
000279231218  httpHeaders(1) = 'Cache-Control: no-cache, no-store';
000280231220
000281231220  // Open File if not open
000282231220  IF %open(SPRACC03L);
000283231220    CLOSE SPRACC03L;
000284231220  ENDIF;
000285231218
000286231218END-PROC GetAllAccounts;
000287231218
000346231218// --------------------------------------------------------------------
000347231218// *
000348231219// HasPostings
000349231218//   Checks if the selected account number is available
000350231218//   in the account postings SPRACP05L logical file
000351231218// *
000352231218// Parameters:  selectedAccountNumber
000353231218// Globals:     -
000354231218// *
000355231221// Returns:     *ON or *OFF
000356231218//---------------------------------------------------------------------
000357231219DCL-PROC HasPostings;
000358231219  DCL-PI *N IND;
000359231219    selectedAccountNumber CHAR(17);
000360231218  END-PI;
000361231218
000362231219  // Account Postings (History) list by Account Number
000363231220  DCL-F SPRACP05L USAGE(*INPUT) KEYED USROPN;
000364231219  DCL-S isPostings IND;
000365231220
000366231220  // Open File if not open
000367231220  IF NOT %open(SPRACP05L);
000368231220    OPEN SPRACP05L;
000369231220  ENDIF;
000370231218
000371231219  SETLL selectedAccountNumber ACPR;
000372231218
000373231218  IF %equal;
000374231219    isPostings = *ON;
000375231218  ELSE;
000376231219    isPostings = *OFF;
000377231218  ENDIF;
000378231220
000380231220  IF %open(SPRACP05L);
000381231220    CLOSE SPRACP05L;
000382231220  ENDIF;
000383231218
000384231219  RETURN isPostings;
000385231219END-PROC;
000386231218
000387231218// --------------------------------------------------------------------
000388231218// *
000389231218// GetHasStatements
000390231218//   Checks if the selected account number is available
000391231218//   in the Statement Header SPRSTH01L logical file
000392231218// *
000393231218// Parameters:  selectedAccountNumber
000394231218// Globals:     -
000395231218// *
000396231219// Returns:     *ON or *OFF
000397231218//---------------------------------------------------------------------
000398231219DCL-PROC HasStatements;
000399231219  DCL-PI *N IND;
000400231219    selectedAccountNumber CHAR(17);
000401231218  END-PI;
000402231218
000403231219  // Statement Headers (Statements) list by Account Number
000404231220  DCL-F SPRSTH01L USAGE(*INPUT) KEYED USROPN;
000405231219  DCL-S isStatements IND;
000406231218
000407231218  SETLL (selectedAccountNumber) STHR;
000408231220
000409231220  // Open File if not open
000410231220  IF NOT %open(SPRSTH01L);
000411231220    OPEN SPRSTH01L;
000412231220  ENDIF;
000413231218
000414231218  IF %equal;
000415231219    isStatements = *ON;
000416231218  ELSE;
000417231219    isStatements = *OFF;
000418231218  ENDIF;
000419231220
000421231220  IF %open(SPRSTH01L);
000422231220    CLOSE SPRSTH01L;
000423231220  ENDIF;
000424231218
000425231219  RETURN isStatements;
000426231219END-PROC;
000427231218
000428231218// --------------------------------------------------------------------
000429231218// *
000430231218// GetHasStandingOrders
000431231218//   Checks if the selected account number is available
000432231218//   in the Recurring Payments SPRSTO04L logical file
000433231218// *
000434231218// Parameters:  selectedAccountNumber
000435231218// Globals:     -
000436231218// *
000437231219// Returns:     *ON or *OFF
000438231218//---------------------------------------------------------------------
000439231219DCL-PROC HasStandingOrders;
000440231219  DCL-PI *N IND;
000441231219    selectedAccountNumber CHAR(17);
000442231218  END-PI;
000443231218
000444231219  // Recurring Payments (Standing Orders) list by Account Number
000445231219  DCL-F SPRSTO04L USAGE(*INPUT) KEYED;
000446231219  DCL-S isStandingOrders IND;
000447231218
000448231218  SETLL (selectedAccountNumber) STOR;
000449231220
000450231220  // Open File if not open
000451231220  IF NOT %open(SPRSTO04L);
000452231220    OPEN SPRSTO04L;
000453231220  ENDIF;
000454231218
000455231218  IF %equal;
000456231219    isStandingOrders = *ON;
000457231218  ELSE;
000458231219    isStandingOrders = *OFF;
000459231218  ENDIF;
000460231220
000461231220  // Open File if not open
000462231220  IF %open(SPRSTO04L);
000463231220    CLOSE SPRSTO04L;
000464231220  ENDIF;
000465231218
000466231219  RETURN isStandingOrders;
000467231218END-PROC;
000468231218
000469231218// --------------------------------------------------------------------
000470231218// *
000471231219// CheckIfDeleted
000472231218//   Checks if the selected account number is of a
000473231218//   deleted account
000474231218// *
000475231219// Parameters:  STAT1, STAT2
000476231218// Globals:
000477231218// *
000478231219// Returns:     *ON or *OFF
000479231218//---------------------------------------------------------------------
000480231219DCL-PROC CheckIfDeleted;
000481231219  DCL-PI *N IND;
000482231219    STAT1 CHAR(1);
000483231219    STAT2 CHAR(2);
000484231218  END-PI;
000485231218
000486231219  DCL-S isDeleted IND;
000487231218
000488231219  IF STAT1 = '2' AND STAT2 =' 1';
000489231219    isDeleted = *ON;
000490231218  ELSE;
000491231219    isDeleted = *OFF;
000492231218  ENDIF;
000493231218
000494231218  RETURN isDeleted;
000495231218END-PROC;
000496231218
