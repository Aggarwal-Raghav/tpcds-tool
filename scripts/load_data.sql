load data inpath '/data/call_center.dat' into table call_center;
load data inpath '/data/catalog_page.dat' into table catalog_page;
load data inpath '/data/catalog_returns.dat' into table catalog_returns;
load data inpath '/data/catalog_sales.dat' into table catalog_sales;
load data inpath '/data/customer.dat' into table customer;
load data inpath '/data/customer_address.dat' into table customer_address;
load data inpath '/data/customer_demographics.dat' into table customer_demographics;
load data inpath '/data/date_dim.dat' into table date_dim;
load data inpath '/data/dbgen_version.dat' into table dbgen_version;
load data inpath '/data/household_demographics.dat' into table household_demographics;
load data inpath '/data/income_band.dat' into table income_band;
load data inpath '/data/inventory.dat' into table inventory;
load data inpath '/data/item.dat' into table item;
load data inpath '/data/promotion.dat' into table promotion;
load data inpath '/data/reason.dat' into table reason;
load data inpath '/data/ship_mode.dat' into table ship_mode;
load data inpath '/data/store.dat' into table store;
load data inpath '/data/store_returns.dat' into table store_returns;
load data inpath '/data/store_sales.dat' into table store_sales;
load data inpath '/data/time_dim.dat' into table time_dim;
load data inpath '/data/warehouse.dat' into table warehouse;
load data inpath '/data/web_page.dat' into table web_page;
load data inpath '/data/web_returns.dat' into table web_returns;
load data inpath '/data/web_sales.dat' into table web_sales;
load data inpath '/data/web_site.dat' into table web_site;

# ./dsqgen -input ../query_templates/templates.lst -template query$i.tpl  -directory ../query_templates/ -dialect netezza -scale 2 -filter > /tmp/raaggarw/query$i.sql done
