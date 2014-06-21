create table gogames character set gbk (
	game_date 		DATE not null,
	game_name 		VARCHAR (160) not null,
	black_player	VARCHAR(32) not null,
	white_player	VARCHAR(32) not null,
	raw_result		VARCHAR(16)	not null, 
	raw_steps		VARCHAR(16) not null,
	result			int not null default -1, 
	steps			int not null default 0, 
	primary key (game_date, game_name, black_player, white_player, raw_result, raw_steps), 
);

desc gogames;
alter table gogames character set gbk;
alter table gogames alter result set default 0;

insert into gogames values (
	'1921-07-14', '1921日本临时比赛', '金井茂', '本因坊秀哉', '白中盘胜', '169手', '2', '169'
);

LOAD DATA LOCAL INFILE "C:\\Users\\FinixLei\\Desktop\\Level\\FocusFinalData.txt" INTO TABLE gogames;

--------------------------------------------------

create table dimension_result (
	result int not null primary key, 
	description VARCHAR(32) not null);
    
alter table dimension_result character set gbk;

insert into dimension_result values ('0', '和棋');
insert into dimension_result values ('1', '黑胜');
insert into dimension_result values ('2', '白胜');
insert into dimension_result values ('-1', '胜负未知');

---------------------------------------------------

create view gogamesview as
    select g.game_date, g.game_name, g.black_player, g.white_player, 
		   dr.description, g.raw_result, g.raw_steps  
	from gogames as g inner join dimension_result as dr 
	where g.result = dr.result; 
    
select * from gogamesview;

---------------------------------------------------

drop procedure WinRateProc;

DELIMITER //
CREATE PROCEDURE WinRateProc(IN start_date DATE, IN end_date DATE, 
							IN player VARCHAR(32) character set GBK, 
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
	(black_player = player or white_player = player) and 
	(result = 0 or result = 1 or result = 2);
	
	set win_rate=win_num/total_num;
	select player, win_num, total_num, win_rate;
END
//
DELIMITER ;

call WinRateProc('1900-01-01', '2013-12-31', '金志锡', @win_num, @total_num, @win_rate);

-------------------------------------------------------------------------

DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `AllPlayersWinRate`()
BEGIN

set @count=0;

select (@count := @count + 1) as seq, 
		rate_t.player, rate_t.win_num, rate_t.all_num, rate_t.win_rate 
from
(
	select win_t.player as player, win_t.num as win_num, (win_t.num + notwin_t.num) as all_num, 
		win_t.num/(win_t.num + notwin_t.num) as win_rate
	from 
	(
		select (b_win.num + w_win.num) as num, b_win.black_player as player
		from
		(
			select count(*) as num, black_player
			from gogames
			where result = 1
			group by black_player
		) b_win
		inner join
		(
			select count(*) as num, white_player
			from gogames
			where result = 2
			group by white_player
		) w_win
		on b_win.black_player = w_win.white_player
	) win_t
	
	inner join
	
	(
		select (b_notwin.num + w_notwin.num) as num, b_notwin.black_player as player
		from 
		(
			select count(*) as num, black_player
			from gogames
			where result = 0 or result = 2
			group by black_player
		) b_notwin
		inner join
		(
			select count(*) as num, white_player
			from gogames
			where result = 0 or result = 1
			group by white_player
		) w_notwin
		on b_notwin.black_player = w_notwin.white_player
	) notwin_t
	on win_t.player = notwin_t.player
	
	where win_t.num + notwin_t.num >= 50
	order by 4 desc
) rate_t;
END
//
DELIMITER ;

call AllPlayersWinRate();