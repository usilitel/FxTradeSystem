

alter  PROCEDURE ntp_calcCorr (@resultCorr float output)
	-- процедура возвращает коэффициент коррел€ции между двум€ р€дами
	-- http://www.sql.ru/forum/1170401/raschet-koefficienta-korrelyacii
	
	-- таблица #t_Corr (X FLOAT, Y FLOAT) должна быть создана и заполнена

AS BEGIN 

SET NOCOUNT ON

	SELECT @resultCorr = SUM((T.X-A.AVG_X)*(T.Y-A.AVG_Y))/(A.STDEVP_X*A.STDEVP_Y*A.C)
	FROM #t_Corr T
	CROSS APPLY (SELECT AVG(X),AVG(Y),STDEVP(X),STDEVP(Y),COUNT(*) FROM #t_Corr)A(AVG_X,AVG_Y,STDEVP_X,STDEVP_Y,C)
	GROUP BY A.STDEVP_X,A.STDEVP_Y,A.C;

/*
	select @resultCorr = SUM((Y-Y_)*(X-X_))/SQRT(sum(POWER((X-X_),2))*sum(POWER((Y-Y_),2)))
	from @t_Corr d
	cross apply(select AVG(X) as X_,AVG(Y) as Y_ from @t_Corr) t

	select @resultCorr = SUM((Y-Y_)*(X-X_))/SQRT(sum(SQUARE((X-X_)))*sum(SQUARE((Y-Y_))))
	from @t_Corr d
	cross apply(select AVG(X) as X_,AVG(Y) as Y_ from @t_Corr) t
*/

END


