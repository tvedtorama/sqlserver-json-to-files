-- geoLocationCode should perhaps be postfixed with (HA,BB) for customer types - since this cannot be properties if codes are to be unique

/* Fetch allocation data, linking addresses to point groups */
SELECT CAST(MAX(TMG.IDMatrikkelGate) as nvarchar(200)) allocationTemplateId,
	(SELECT CAST(OtherTMG.IDPunkt as nvarchar(200)) "id", (OtherTMG.IDPunktRolle + 1) "priority" FROM [BossID].[dbo].TilordningMatrikkelGate OtherTMG WHERE
			TMG.IDMatrikkelGate = OtherTMG.IDMatrikkelGate ORDER BY IDPunktRolle FOR JSON PATH) points,
	MAX(TMG.TilordneHusholdning) as "properties.assignHousehold",
	MAX(TMG.TilordneBedrift) as "properties.assignBusiness",
	MAX(MG.AdresseGate) as "externalKeys.geoLocationCode",
	MAX(MG.Gateadresse) as "properties.geoLocationName",
	MAX(TMG.IDMatrikkelGate) as "externalKeys.bossId"
	FROM [BossID].[dbo].TilordningMatrikkelGate TMG
	INNER JOIN [BossID].[dbo].MatrikkelGate MG ON TMG.IDMatrikkelGate = MG.IDMatrikkelGate
	INNER JOIN [BossID].[dbo].BossIDTjeneste T ON TMG.IDTjeneste = T.IDTjeneste 	   
	GROUP BY TMG.IDMatrikkelGate -- Group on root level, list on sub-query level
	FOR JSON PATH
