SELECT
		'IMPORT_EVENT_BLOCK' as type,
		'EVENT' as scenarioId,
		JSON_QUERY((SELECT
			CONVERT(date, k0.HendelseDato) as "theDay",
			CONVERT(nvarchar, IDTjeneste) as "serviceClass",
			JSON_QUERY((SELECT HendelseDato as timestamp,
				'ACCEPTED' as result,
				CASE K.IDTommeHendelseType WHEN 1 THEN 'OUT' WHEN 10 THEN 'IN' ELSE 'EMPTY' END as type,
				CASE WHEN TE.IDPunktBarn IS NULL THEN TE.TjenesteIDEnhet ELSE 'C' + CONVERT(nvarchar, TE.IDPunktBarn) END as pointRef,
				'ID' as pointRefType,
				'0' as value,
				'' as Unit,
				CASE WHEN K.IDTommeHendelseType = 1 THEN 'S' + CONVERT(nvarchar, TE.IDTjeneste) ELSE NULL END as identityId,
				CASE WHEN K.IDTommeHendelseType = 1 THEN 'POINT_REF' ELSE NULL END as identityType
				FROM TommeHendelser K 
					LEFT OUTER JOIN TommeEnhet TE ON K.IDTommeEnhet = TE.IDTommeEnhet
				-- Note: When the IDTjeneste condition was added, to fix duplicate events among services, the query slowed down considerably
				WHERE CONVERT(date, K.HendelseDato) = CONVERT(date, K0.HendelseDato) AND K.IDTjeneste = k0.IDTjeneste FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM TommeHendelser AS K0 WHERE K0.HendelseDato >= @startDate AND K0.HendelseDato < @endDate GROUP BY CONVERT(date, K0.HendelseDato), IDTjeneste FOR JSON Path