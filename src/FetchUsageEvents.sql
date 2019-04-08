-- declare @startDate DateTime = '2019-03-15 22:00:00.000'
-- declare @endDate DateTime = '2019-03-18 22:00:00.000' -- note the rounding below...
-- declare @IDTjeneste int = 1

declare @timeZoneHack int = 1;

WITH D(dayDiff, IDTjeneste) AS (
	SELECT DATEDIFF(hour, @startDate, DATEadd(hour, @timeZoneHack, HendelseTidspunkt)) / 24, IDTjeneste FROM [BossID].[dbo].KundeHendelser AS K0
		WHERE DATEadd(hour, @timeZoneHack, HendelseTidspunkt) BETWEEN @startDate AND @endDate
		GROUP BY DATEDIFF(hour, @startDate, DATEadd(hour, @timeZoneHack, HendelseTidspunkt)) / 24, IDTjeneste
), Y(startDate, endDate, IDTjeneste) AS (
	SELECT DATEADD(day, D.dayDiff, @startDate), DATEADD(day, D.dayDiff + 1, @startDate), IDTjeneste FROM D
)
SELECT
		'IMPORT_EVENT_BLOCK' as type,
		'EVENT' as scenarioId,
		JSON_QUERY((SELECT
			CONCAT((SELECT Navn FROM [BossID].[dbo].BossIDTjeneste B WHERE B.IdTjeneste = K0.idtjeneste) , '_', CONVERT(nvarchar, IDTjeneste)) as "serviceClass",
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'}, K0.startDate)) * 1000 as dataWindowStart,
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'}, DATEADD(millisecond, -1, K0.endDate))) * 1000 as dataWindowEnd,
			JSON_QUERY((SELECT
				DATEadd(hour, @timeZoneHack, HendelseTidspunkt) timestamp,
				CASE K.IDHendelseType WHEN 1 THEN 'ACCEPTED' ELSE 'REJECTED' END as result,
				'USE' as type,
				'C' + CONVERT(nvarchar, K.IDPunktBarn) as pointRef,
				'ID' as pointRefType,
				Verdi as "properties.weight",
				CASE K.IDPunktEnhet WHEN 1 THEN 'G' WHEN 3 THEN 'KG' ELSE PE.Enhet END as "properties.weightUnit",
				CASE IDFraksjon WHEN 1 THEN '0001' WHEN 2 THEN '9999' WHEN 3 THEN '1299' WHEN 6 THEN '1231' WHEN 7 THEN '1700' WHEN 8 THEN '1261' END as "properties.wasteCategory",
				CASE WHEN B.IDBrikke IS NULL THEN Rfid ELSE B.UIDISO14443A END as identityId,
				'RFID_ISO' as identityType
				FROM [BossID].[dbo].KundeHendelser K 
					INNER JOIN [BossID].[dbo].PunktEnhet PE ON K.IDPunktEnhet = PE.IDPunktEnhet
					LEFT OUTER JOIN [BossID].[dbo].Brikker B ON K.IDBrikke = B.IDBrikke
				-- Note: When the IDTjeneste condition was added, to fix duplicate events among services, the query slowed down considerably
				WHERE (DATEadd(hour, @timeZoneHack, HendelseTidspunkt) BETWEEN K0.startDate AND K0.endDate) AND K.IDTjeneste = k0.IDTjeneste
				ORDER BY k.HendelseTidspunkt ASC
				FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM Y AS K0 ORDER BY K0.startDate
	FOR JSON Path
