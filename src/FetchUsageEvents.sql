SELECT
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
				Verdi as "properties.weight",
				CASE K.IDPunktEnhet WHEN 1 THEN 'G' WHEN 3 THEN 'KG' ELSE PE.Enhet END as "properties.weightUnit",
				CASE IDFraksjon WHEN 1 THEN '0001' WHEN 2 THEN '9999' WHEN 3 THEN '1299' WHEN 6 THEN '1231' WHEN 7 THEN '1700' WHEN 8 THEN '1261' END as "properties.wasteCategory",
				CASE WHEN B.IDBrikke IS NULL THEN Rfid ELSE B.UIDISO14443A END as identityId,
				'RFID_ISO' as identityType
				FROM KundeHendelser K 
					INNER JOIN PunktEnhet PE ON K.IDPunktEnhet = PE.IDPunktEnhet
					LEFT OUTER JOIN Brikker B ON K.IDBrikke = B.IDBrikke
				-- Note: When the IDTjeneste condition was added, to fix duplicate events among services, the query slowed down considerably
				WHERE CONVERT(date, K.HendelseTidspunkt) = CONVERT(date, K0.HendelseTidspunkt) AND K.IDTjeneste = k0.IDTjeneste FOR JSON PATH)) AS "eventList"
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS "payload"
	FROM KundeHendelser AS K0 WHERE K0.HendelseTidspunkt >= @startDate AND K0.HendelseTidspunkt < @endDate GROUP BY CONVERT(date, K0.HendelseTidspunkt), IDTjeneste FOR JSON Path