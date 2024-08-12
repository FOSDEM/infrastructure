CREATE TABLE IF NOT EXISTS fosdem (
	roomname varchar(16) not null primary key,
	building varchar(16) not null,
	voctop varchar(255),
	slides varchar(255),
	cam varchar(255)
);
create unique index fosdem_voctop on fosdem(voctop);
create unique index fosdem_cam on fosdem(cam);
create unique index fosdem_slides on fosdem(slides);
