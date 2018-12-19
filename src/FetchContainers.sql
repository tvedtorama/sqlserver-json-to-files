/*  Run this in your database if it fails.
DROP FUNCTION IF EXISTS dbo.ufnToRawJsonArray
GO
CREATE FUNCTION
[dbo].[ufnToRawJsonArray](@json nvarchar(max), @key nvarchar(400)) returns nvarchar(max)
AS BEGIN
       declare @new nvarchar(max) = replace(@json, CONCAT('},{"', @key,'":'),',')
       return '[' + substring(@new, 1 + (LEN(@key)+5), LEN(@new) -2 - (LEN(@key)+5)) + ']'
END */

/* Find containers among emptying receivers.  These are AccessPoints */
WITH ContRows (id, name, tag, services, parentId, type) AS (
	SELECT TjenesteIDEnhet as id, Navn as name, merkelapp as tag, 
		(dbo.ufnToRawJsonArray((SELECT 'S' + convert(nvarchar, TE2.IDTjeneste) as serviceId FROM TommeEnhet TE2 WHERE TE2.TjenesteIDEnhet = TE.TjenesteIDEnhet FOR JSON PATH)
			, 'serviceId')) services,
		'CONTAINER_ROOT' as parentId,
		'CONTAINER' as type
		FROM TommeEnhet TE WHERE TE.IDTommeEnhet IN (SELECT MAX(IDTommeEnhet) FROM TommeEnhet TEG GROUP BY TjenesteIDEnhet HAVING MAX(IDPunkt) IS NULL)
	UNION
		SELECT 'CONTAINER_ROOT' as id, 'Containere' as name, null as tag, NULL as services, '' as parentId, 'CONTAINER_ROOT' as type
) SELECT id as accessPointId, name, tag as 'externalKeys.tag', id as 'externalKeys.serviceGuid', JSON_QUERY(services) as 'properties.services', type, parentId FROM ContRows FOR JSON PATH
