drop procedure WinRateProc;

DELIMITER //
CREATE PROCEDURE WinRateProc(IN start_date DATE, IN end_date DATE, 
						  IN player VARCHAR(16), 
						  OUT win_num int, OUT total_num int, OUT win_rate double)
BEGIN
	select count(*) into win_num from rankinglist.gogames
	where 
	game_date >= start_date and game_date <= end_date and
	(
		(black_player = player and result = 1) or 
		(white_player = player and result = 2)
	); 
	
	select count(*) into total_num from rankinglist.gogames
	where 
	game_date >= start_date and game_date <= end_date and
	(black_player = player or white_player = player);
	
	set @win_rate=@win_num/@total_num;
	select @player, @win_num, @total_num, @win_rate;
END
//
DELIMITER ;

call WinRateProc('2013-01-01', '2013-07-26', '½ğÖ¾Îı', @win_num, @total_num, @win_rate);

