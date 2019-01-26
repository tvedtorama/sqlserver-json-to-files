WITH Operator (id, name, description, guid, shortName) AS (
	SELECT IDKundeAktor, Navn, Beskrivelse, GUIDAktor, KortNavn FROM [BossID].[dbo].KundeAktor
)
SELECT CAST(Operator.id AS nvarchar(200)) as operatorId, name, description,
	guid as 'externalKeys.guid',
	shortName as 'externalKeys.shortName'
	FROM Operator
	FOR JSON PATH
