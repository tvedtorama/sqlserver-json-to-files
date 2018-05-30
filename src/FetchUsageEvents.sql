SELECT TOP 10 
		'IMPORT_EVENT_BLOCK' as type,
		'EVENT' as scenarioId,
		JSON_QUERY((SELECT
			CONVERT(date, k0.HendelseTidspunkt) as "theDay",
			CONVERT(nvarchar, IDTjeneste) as "serviceClass",
			JSON_QUERY((SELECT HendelseTidspunkt as timestamp,
				CASE K.IDHendelseType WHEN 1 THEN 'ACCEPTED' ELSE 'REJECTED' END as result,
				'USE' as type,
				'C' + CONVERT(nvarchar, K.IDPunktBarn) as pointRef,
				'ID' as pointRefType,
				Verdi as value,
				CASE K.IDPunktEnhet WHEN 1 THEN 'Weight/G' WHEN 3 THEN 'Weight/KG' ELSE PE.Enhet END as unit,
				CASE WHEN B.IDBrikke IS NULL THEN Rfid ELSE B.UIDISO14443A END as identityId,
				'RFID_ISO14443A' as identityType
				FROM KundeHendelser K 
					INNER JOIN PunktEnhet PE ON K.IDPunktEnhet = PE.IDPunktEnhet
					LEFT OUTER JOIN Brikker B ON K.IDBrikke = B.IDBrikke
				WHERE CONVERT(date, K.HendelseTidspunkt) = CONVERT(date, K0.HendelseTidspunkt) FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM KundeHendelser AS K0  WHERE K0.HendelseTidspunkt >= @startDate AND K0.HendelseTidspunkt < @endDate GROUP BY CONVERT(date, K0.HendelseTidspunkt), IDTjeneste FOR JSON Path