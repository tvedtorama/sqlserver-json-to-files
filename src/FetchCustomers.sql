WITH Props (IDKundeEnhet, matrikkel, geoLocationCode, geoLocationName, description) AS (
	-- The reason for this WITH-block is to treat properties differently between customer types, could have been a CASE for each prop instead.  This little twist also led to issues with the JSON formatting below.
	SELECT
		IDKundeEnhet,
		Matrikkel AS "matrikkel",
		AdresseGate AS "geoLocationCode",
		Gateadresse AS "geoLocationName",
		Beskrivelse AS "description"
		FROM KundeEnhet Props WHERE IDKundeEnhetsType IN (0, 1, 2)
	UNION SELECT IDKundeEnhet, NULL AS "matrikkel",
		NULL AS "geoLocationCode",
		NULL AS "geoLocationName",
		Beskrivelse AS "description"
		FROM KundeEnhet Props WHERE IDKundeEnhetsType NOT IN (0, 1, 2) )
SELECT
CAST(Cust.IDKundeEnhet AS nvarchar(200)) AS "customerId",
Cust.Navn as "name",
'' as "parentId",
JSON_QUERY(CONCAT(
	'{',
		(SELECT CONCAT('"S', CONVERT(nvarchar, T.IDTjeneste), '.ServiceId": "',
			CASE WHEN T.I3&32 = 0 THEN KET.IDTjenesteKunde ELSE CONVERT(NVARCHAR(50), KET.GUIDTjenesteKunde) END, '",') AS [text()]
		FROM KundeEnhetTjeneste KET INNER JOIN BossIDTjeneste T ON KET.IDTjeneste=T.IDTjeneste
		WHERE KET.IDKundeEnhet=Cust.IDKundeEnhet
		FOR XML PATH ('')),
		'"PAAvtaleID": "', Cust.IDAvtale, '",',
		'"PAAvtaleGUID": "', Cust.GUIDAvtale, '"',
	'}')) AS "externalKeys",
JSON_QUERY((
	SELECT matrikkel, geoLocationCode, geoLocationName, description FROM Props WHERE Props.IDKundeEnhet = Cust.IDKundeEnhet
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "properties",
CustType.KortNavn AS "customerType",
JSON_QUERY(
	(SELECT 
		CAST(Chip.serienummer as nvarchar(200)) as id
		FROM KundeBrikker CustCard 
		INNER JOIN Brikker Chip ON Chip.IDBrikke = CustCard.IDBrikke 
		WHERE Cust.IDKundeEnhet = CustCard.IDKundeEnhet AND CustCard.Slettet <> 1 FOR JSON PATH)
	) identities,
(SELECT CAST(CustPoint.IDPunkt as nvarchar(200)) "id", (CustPoint.IDPunktRolle + 1) "priority" FROM KundeEnhetPunkter CustPoint WHERE
			Cust.IDKundeEnhet = CustPoint.IDKundeEnhet ORDER BY IDPunktRolle FOR JSON PATH) points
FROM KundeEnhet Cust
INNER JOIN KundeEnhetsType CustType ON Cust.IDKundeEnhetsType = CustType.IDKundeEnhetsType
FOR JSON PATH
