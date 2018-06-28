	SELECT Chip.Serienummer as identityId,
	    -- CAST(Chip.IDBrikke as nvarchar(200)) AS identityId,
		ChipCategory.KortNavn as identityType,
		Chip.UIDEM4102 as "externalKeys.EM",
		Chip.UIDISO14443A as "externalKeys.ISO",
		CAST(Chip.IDBrikke as nvarchar(200)) AS "externalKeys.BossID",
		CASE CC.Sperret WHEN 1 THEN 'DISABLED' ELSE NULL END as 'status'
		FROM Brikker Chip INNER JOIN BrikkeKategori ChipCategory ON Chip.IDBrikkeKategori = ChipCategory.IDBrikkeKategori
		LEFT OUTER JOIN KundeBrikker CC ON CC.IDBrikke = Chip.IDBrikke
		FOR JSON PATH
