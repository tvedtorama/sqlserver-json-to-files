-- declare @startDate DateTime = '2019-04-03 00:00:00.000'
-- declare @endDate DateTime = '2019-04-04 00:00:00.000'

SELECT
		'IMPORT_EVENT_BLOCK' as type,
		'EVENT' as scenarioId,
		JSON_QUERY((SELECT
			CONVERT(date, k0.HendelseDato) as "theDay",
			CONCAT((SELECT Navn FROM [BossID].[dbo].BossIDTjeneste B WHERE B.IdTjeneste = K0.idtjeneste) , '_EMPTY_', CONVERT(nvarchar, IDTjeneste)) as "serviceClass",
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'},@startDate)) * 1000 as dataWindowStart,
			CONVERT(bigint, DATEDIFF(second,{d '1970-01-01'},@endDate)) * 1000 as dataWindowEnd,
			JSON_QUERY((SELECT HendelseDato as timestamp,
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
				WHERE CONVERT(date, K.HendelseDato) = CONVERT(date, K0.HendelseDato) AND K.IDTjeneste = k0.IDTjeneste FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM [BossID].[dbo].TommeHendelser AS K0
	WHERE K0.HendelseDato >= @startDate AND K0.HendelseDato < @endDate
	GROUP BY CONVERT(date, K0.HendelseDato), IDTjeneste
	FOR JSON Path
