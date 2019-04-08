-- declare @startDate DateTime = '2019-03-15 22:00:00.000'
-- declare @endDate DateTime = '2019-03-18 22:00:00.000' -- note the rounding below...
declare @timeZoneHack int = 1;

WITH D(dayDiff, IDTjeneste) AS (
	SELECT DATEDIFF(hour, @startDate, DATEadd(hour, @timeZoneHack, HendelseDato)) / 24, IDTjeneste FROM [BossID].[dbo].TommeHendelser AS K0
		WHERE DATEadd(hour, @timeZoneHack, HendelseDato) BETWEEN @startDate AND @endDate
		GROUP BY DATEDIFF(hour, @startDate, DATEadd(hour, @timeZoneHack, HendelseDato)) / 24, IDTjeneste
), Y(startDate, endDate, IDTjeneste) AS (
	SELECT DATEADD(day, D.dayDiff, @startDate), DATEADD(day, D.dayDiff + 1, @startDate), IDTjeneste FROM D
)
SELECT
	'IMPORT_EVENT_BLOCK' as type,
	'EVENT' as scenarioId,
	JSON_QUERY((SELECT
			-- CONVERT(date ,DATEadd(hour, @timeZoneHack, HendelseDato)) as "theDay",
			CONCAT((SELECT Navn FROM [BossID].[dbo].BossIDTjeneste B WHERE B.IdTjeneste = K0.idtjeneste) , '_EMPTY_', CONVERT(nvarchar, IDTjeneste)) as "serviceClass",
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'},K0.startDate)) * 1000 as dataWindowStart,
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'},K0.endDate)) * 1000 as dataWindowEnd,
			JSON_QUERY((SELECT 
				DATEadd(hour, @timeZoneHack, HendelseDato) as timestamp,
				'ACCEPTED' as result,
				CASE K.IDTommeHendelseType WHEN 1 THEN 'OUT' WHEN 10 THEN 'IN' ELSE 'EMPTY' END as type,
				CASE WHEN TE.IDPunktBarn IS NULL THEN TE.TjenesteIDEnhet ELSE 'C' + CONVERT(nvarchar, TE.IDPunktBarn) END as pointRef,
				'ID' as pointRefType,
				CASE WHEN K.IDTommeHendelseType = 1 THEN 'S' + CONVERT(nvarchar, TE.IDTjeneste) ELSE NULL END as identityId,
				CASE WHEN K.IDTommeHendelseType = 1 THEN 'POINT_REF' ELSE NULL END as identityType,
				CASE K.IDFraksjon WHEN 1 THEN '0001' WHEN 2 THEN '9999' WHEN 3 THEN '1299' WHEN 6 THEN '1231' WHEN 7 THEN '1700' WHEN 8 THEN '1261' END as "properties.fraction"
				FROM [BossID].[dbo].TommeHendelser K 
					LEFT OUTER JOIN [BossID].[dbo].TommeEnhet TE ON K.IDTommeEnhet = TE.IDTommeEnhet
				-- Note: When the IDTjeneste condition was added, to fix duplicate events among services, the query slowed down considerably
				WHERE (DATEadd(hour, @timeZoneHack, HendelseDato) BETWEEN K0.startDate AND K0.endDate) AND K.IDTjeneste = k0.IDTjeneste
				ORDER BY k.HendelseDato ASC
				FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM Y AS K0 ORDER BY k0.startDate ASC
	FOR JSON AUTO

