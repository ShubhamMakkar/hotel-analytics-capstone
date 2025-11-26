
create database hotels_project;
use hotels_project;

# changing column name total_discount% to total_discount 
alter table bookings rename column `total_discount%` to total_discount;

# adding column Revenue in bookings table
alter table bookings add column Revenue float not null;

# Updating column Revenue in bookings table 

update bookings set Revenue = 
round(((num_of_rooms * price_per_day) * total_discount) / 100,2);

select * from bookings;
select * from hotels; 
select * from ratings; 
select * from transactions; 
select * from users; 

select distinct ratings from ratings;

# distinct ratings = Dissatisfied, Good, Average, Excellent, Fair, Very Good, Very Dissatisfied

-- Creating Column "Rating_Score":

alter table ratings add column Rating_Score int not null; 

update ratings set Rating_Score = 
case 
when ratings = 'Very Dissatisfied' then 1
when ratings = 'Dissatisfied' then 2
when ratings = 'Fair' then 3
when ratings = 'Average' then 4
when ratings = 'Good' then 5
when ratings = 'Very Good' then 6
when ratings = 'Excellent' then 7
else null
end;

select * from ratings;

-- Table Structure

# users -------- (user_id, user_name, contact, age)
# bookings ----- (booking_id, hotel_id, user_id, booking_date, check_in_date, check_out_date,
# --------------  num_of_rooms, room_type, price_per_day, total_discount%, Revenue)
# hotels ------- (hotel_id, hotel_name, city, location, contact, total_rooms)
# transactions - (booking_id, transaction_id, transaction_mode, transaction_status)
# ratings ------ (booking_id, ratings, Rating_Score)

--  Hotel KPI's

# 1) Total number of hotels.
 
select count(distinct hotel_id) as Total_Hotels from hotels;

-- Inference - Total Number of Hotels are 300. 

# 2) Total available hotel rooms across all hotels. 

select sum(total_rooms) as Total_Available_Rooms from hotels;

-- Inference - There are 49847 total available hotel rooms across all hotels. 

# 3) Average number of rooms per hotel.

select round((Total_Available_Rooms / Total_Hotels),2) as Average_Rooms_Per_Hotel from 
(select count(distinct hotel_id) as Total_Hotels, sum(total_rooms) as Total_Available_Rooms
from hotels) as dt;

-- Inference - Average rooms per hotel are 166.16

# 4) Hotels count by city.

select city, count(hotel_id) as Hotels_Count 
from hotels
group by city
order by Hotels_Count desc;

-- Inference - Delhi has recorded the highest number of Hotels_Count (57), followed by 
--             Lucknow (55) and Mumbai (54).  

# 5) Active Hotels

select count(*) as Active_Hotels from
(select h.hotel_id, count(b.booking_id) as Total_Bookings
from hotels as h left join bookings as b on b.hotel_id = h.hotel_id
group by h.hotel_id) as dt
where dt.Total_Bookings >0; 

-- Inference - Total Number of Active Hotels are 121. 

# 6) Inactive Hotels

select count(*) as Active_Hotels from
(select h.hotel_id, count(b.booking_id) as Total_Bookings
from hotels as h left join bookings as b on b.hotel_id = h.hotel_id
group by h.hotel_id) as dt
where dt.Total_Bookings =0; 

-- Inference - Total Number of Inactive Hotels are 179 

-- Hotel Insights 

# 1) Hotel wise occupacy rate (No_of_rooms_booked / Total_Rooms).

select *, concat(Occupacy_Rate,'%') as Occupacy_Rate from
(select *, round((Rooms_Booked / Total_Rooms)*100,2) as Occupacy_Rate from
(select h.Hotel_Name, h.Total_Rooms, sum(b.num_of_rooms) as Rooms_Booked
from bookings as b join hotels as h on b.hotel_id = h.hotel_id
group by h.Hotel_Name, h.total_rooms) as dt
order by Occupacy_Rate desc) as dt2 ;

-- Inference - Hotel wise occupacy analysis shows variation in room analysis across prpoerties. 
 
# 2) Top 5 hotels based on total revenue.

select h.Hotel_Name, round(sum(b.Revenue),2) as Total_Revenue
from hotels as h join bookings as b on b.hotel_id = h.hotel_id
group by h.hotel_name
order by Total_Revenue desc limit 5;
 
-- Inference - Countryside Oasis leads with the highest total_revenue (₹41,222),
--             followed by Country Charm B&B with (₹40,437).   

# 3) Month by Month Performance of Hotels.

select *, concat(round(coalesce((Difference / Prev_Month_Revenue) * 100,0),2),'%') as `MOM% Change` from
(select *, round((Curr_Month_Revenue - Prev_Month_Revenue),2) as Difference from
(select *, lag(Curr_Month_Revenue,1,0) over () as Prev_Month_Revenue from
(select year(b.Check_In_Date) as Year, month(b.Check_In_Date) as Month, 
round(sum(b.Revenue),2) as Curr_Month_Revenue
from bookings as b join hotels as h on h.Hotel_id = b.Hotel_Id
group by Year, Month
order by Year, Month) as dt) as dt2) as dt3;

-- Inference - Hotel Revenue shows strong seasonal variation,  with peak growth observed in 
--             July 2023 (101.16%) followed by September 2023 (88.18%).

# 4) Top Cities Contributing to Total Revenue and Revenue Contribution.

select City, Revenue, concat(round((Revenue / Total_Revenue) * 100,2),'%') as Revenue_Contribution from
(select *, sum(Revenue) over () as Total_Revenue from
(select h.City, round(sum(b.Revenue),2) as Revenue
from hotels as h join bookings as b on h.hotel_id = b.hotel_id
group by h.City) as dt) as dt2
order by dt2.Revenue desc;

-- Inference - Mumbai contributes the highest share (21.95%), followed by Lucknow (19.99%) and 
--             Pune (17.4%).  

# 5) Top 10 Hotels with Highest Excellent Ratings.

select h.Hotel_Name, count(r.Ratings) as Ratings_Count
from hotels as h join bookings as b on h.hotel_id = b.hotel_id
join ratings as r on r.booking_id = b.booking_id
where r.ratings = 'Excellent'
group by h.Hotel_Name
order by Ratings_Count desc
limit 10;

-- Inference - Charming Cottage leads the Top 10 hotels with the highest number of "Excellent" ratings,
--             followed by Trident Hotel and Countryside Oasis.

-- Bookings KPI's 

# 1) Total Bookings

select count(booking_id) as Total_Bookings from bookings;

-- Inference - There are total of 800 bookings.

# 2) Total Revenue

select round(sum(Revenue),2) as Total_Revenue from bookings;  

-- Inference - The hotels collectively generated total revenue of Rs 1426233.73/- .

# 3) Total Rooms Booked

select sum(num_of_rooms) as Total_Rooms_Booked from bookings; 

-- Inference - Total number of 1994 rooms were booked. 

# 4) Average length of stay

select round(avg(Stay_Days),2) as Average_Length_of_Stay from
(select check_in_date, check_out_date, datediff(check_out_date,check_in_date) as Stay_Days
from bookings) as dt;

-- Inference - Average guest stay duration is 5.50 days.

# 5) Average revenue per booking

select round((sum(revenue) / count(booking_id)),2) as `Average Revenue Per Booking`
from bookings;	

-- Inference - The average revenue per booking is Rs 1782.79/- . 

-- Bookings Insights

# 1) City-wise Total Revenue & Bookings Count 

select h.City, round(sum(b.revenue),2) as Total_Revenue, count(b.booking_id) as Total_Bookings
from hotels as h join bookings as b on b.hotel_id = h.hotel_id
group by h.City
order by Total_Revenue desc;

-- Inference - Mumbai city has recorded the highest revenue (313123.22),
--             with highest number of bookings(163).

# 2) Year wise Quarterly Booking Trends 

select year(booking_date) as Year, quarter(booking_date) as Quarter, count(booking_id) as Total_Bookings
from bookings
group by Year, Quarter
order by Year, Quarter;

-- Inference - Bookings were highest at the last quarter of year 2023 (129), 
--             while 2024 bookings were slightly lower and the lowest number of bookings were 
--             recorded in the last quarter of year 2024 (72).   

# 3) Room Type Popularity & Revenue Contribution

select Room_Type, Total_Bookings, concat(round((Revenue / Total_Revenue)*100,2),'%') as Revenue_Contribution from
(select *, sum(Revenue) over () as Total_Revenue from
(select Room_Type, count(booking_id) as Total_Bookings, round(sum(Revenue),2) as Revenue
from bookings
group by Room_Type) as dt) as dt2
order by dt2.Total_Bookings desc;

-- Inference - "Luxury" room_type has recoded the highest number of total_bookings (219),
--             along with highest revenue_contribution (62.91%).   

# 4) Impact of Discounts on Bookings Volume

select case
when total_discount >=0 and total_discount <6 then '0-5%'
when total_discount >=6 and total_discount <11 then '6-10%'
else '11-15%'
end as Discount_group, count(booking_id) as Total_Bookings
from bookings
group by Discount_group
order by Total_Bookings desc;

-- Inference - Lower discounts (0-5%) get the highest number of bookings (321),
--             while higher discounts (11-15%) got the lowest number of bookings (200).  

# 5) Peak Booking Months Across All Hotels (Top 3)

select monthname(booking_date) as Month_Name, count(Booking_id) as Total_Bookings
from bookings 
group by Month_Name
order by Total_Bookings desc
limit 3;

-- Inference - July has the highest bookings (96) followed by October (87) and (85),
--             these three are the busiest months for hotel stays.  

# 6) Running Total Revenue across months  

select Year, Month_Name, Revenue, Running_Revenue from
(select *, round(sum(Revenue) over (order by Year, Month),2) as Running_Revenue
from
(select year(check_in_date) as Year, monthname(check_in_date) as Month_Name,
month(check_in_date) as Month, round(sum(Revenue),2) as Revenue 
from bookings
group by Year, Month_Name, Month
order by Year, Month) as dt) as dt2;

-- Inference - The running total revenue shows that how earnings stacked up month by month,
--             growing from Rs 57969.39/- in April 2023 to Rs 1426233.73/- in December 2024.

# 7) MOM% Change (Growth)

select Year, Month_Name, Current_Month_Revenue, Previous_Month_Revenue, Diff,
concat(coalesce(round((Diff / Previous_Month_Revenue)*100,2),0),'%') as `MOM% Change` from
(select *, round((Current_Month_Revenue - Previous_Month_Revenue),2)  as Diff from
(select *, lag(Current_Month_Revenue,1,0) over () as Previous_Month_Revenue from
(select year(check_in_date) as Year, month(check_in_date) as Month,
monthname(check_in_date) as Month_Name, round(sum(Revenue),2) as Current_Month_Revenue 
from bookings
group by Year, Month, Month_Name
order by Year, Month) as dt) as dt2) as dt3;

-- Inference - There is no consistent pattern in month-to-month growth. The business had several,
--             strong growth months (July 2023, September 2023), but also month with negative
--             growth like (December 2024, August 2024).       

-- Transactions KPI's

# 1) Total number of Transactions

select count(transaction_id) as Total_Transactions from transactions; 

-- Inference - Total number of transactions are 800. 

# 2) Successful Transactions Rate

with cte1 as 
(select count(transaction_id) as Total_Transactions from transactions),

cte2 as 
(select count(transaction_status) as Complete_Transactions
from transactions
where transaction_status = 'complete')

select concat(round((cte2.Complete_Transactions / cte1.Total_Transactions)*100,2),'%') as `Successful_Transactions%`
from cte1,cte2;

-- Inference - 89.13% of transactions are successfully completed out of total transactions. 

# 3) Total Transactions Revenue

select round(sum(b.Revenue),2) as Total_Transactions_Revenue 
from transactions as t join bookings as b on b.booking_id = t.booking_id;

-- Inference - Rs 1426233.73/- is the total revenue generated by all the transactions. 

# 4) Total Revenue from successful Transactions

select round(sum(b.Revenue),2) as Successful_Transactions_Revenue 
from bookings as b join transactions as t on b.booking_id = t.booking_id
where t.transaction_status = 'complete';

-- Inference - Rs 1281814.73/- is the total revenue generated by successful transactions.

# 5) Transactions failure rate

with cte1 as  
(select count(transaction_id) as Total_Transactions from transactions),

cte2 as 
(select count(transaction_id) as Failed_Transactions
from transactions 
where transaction_status = 'incomplete')

select concat(round((cte2.Failed_Transactions / cte1.Total_Transactions)*100,2),'%') as Transactions_Failure_Rate
from cte1, cte2;

-- Inference - 10.88% transactions are failed out of total transactions. 

-- Transactions Insights 

# 1) Transaction Mode Distribution

select Transaction_Mode, concat(round((Transactions / Total_Transactions)*100,2),'%') as Share from
(select *, sum(Transactions) over () as Total_Transactions from
(select Transaction_Mode, count(transaction_id) as Transactions
from transactions
group by Transaction_Mode) as dt) as dt2;
 
-- Inference - "Cash" and "Credit Card" are the most preferred transaction mode with 22% share, 
--             while other transaction modes have almost equally shares.

# 2) Payment mode preference across all customers

select Transaction_Mode, count(Transaction_Mode) as Total_Transactions from
(select *, dense_rank() over (partition by user_name order by Transactions desc) as Rnk from
(select  u.user_name,  t.transaction_mode, count(t.transaction_mode) as Transactions
from transactions as t join bookings as b on t.booking_id = b.booking_id
join users as u on u.user_id = b.user_id
group by u.user_name,  t.transaction_mode
order by user_name) as dt) as dt2
where dt2.Rnk = 1
group by Transaction_Mode
order by Total_Transactions desc; 

-- Inference - "Credit Card" and "Cash" are the most preferred transaction mode among customers,
--             with 158 and 155 transactions respectively.  

# 3) Month wise transaction success trend

select Year, Month_Name, Transactions from
(select year(b.booking_date) as Year, month(b.booking_date) as Month,
monthname(b.booking_date) as Month_Name, count(t.transaction_id) as Transactions
from transactions as t join bookings as b on t.booking_id = b.booking_id
where t.transaction_status = 'complete'
group by Year, Month, Month_Name
order by Year, Month) as dt; 

-- Inference - Overall system maintains a stable success volums over months,
--             with slightly high success transactions in May 2023 (47), Dec 2023 (45) and July 2024 (50).  

# 4) Revenue distribution by payment mode

select Transaction_Mode, Revenue, concat(round((Revenue / Total_Revenue)*100,2),'%') as Share from
(select *, sum(Revenue) over () as Total_Revenue from
(select t.Transaction_Mode, round(sum(b.Revenue),2) as Revenue 
from transactions as t join bookings as b on t.booking_id = b.booking_id
group by t.Transaction_Mode) as dt) as dt2;

-- Inference - Revenue is fairly distributed among all the transaction modes,
--             with "cash" (23.81%) and "credit card" (22.01%) contributing the most.   

# 5) Average transaction value by transaction mode

select t.Transaction_Mode, round(avg(b.Revenue),2) as Average_Transaction_Value 
from bookings as b join transactions as t on t.booking_id = b.booking_id
group by t.Transaction_Mode
order by Average_Transaction_Value desc;

-- Inference - "Debit Card" has recorded the highest average_transaction_value (Rs 2032.14/-) across all 
--             transaction modes, followed by "cash" with (Rs 1929,34/-).  

# 6) Trend of increasing or decreasing cashless payments

select Year, Month_Name, Total_Transactions from
(select year(b.booking_date) as Year, month(b.booking_date) as Month,
monthname(b.booking_date) as Month_Name, count(t.transaction_id) as Total_Transactions
from bookings as b join transactions as t on b.booking_id = t.booking_id
where t.Transaction_Mode != 'cash'
group by Year, Month, Month_Name
order by Year, Month) as dt;

-- Inference - Cashless transactions shows a fluctuating pattern across month,
--             with no upward or downward trend.

-- Users KPI's

# 1) Total users

select count(user_id) as Total_Users 
from users;
  
-- Inference - The platforms has reached 1000 users overall.   
  
# 2) Active users

select count(distinct user_id) as Active_Users
from bookings;

-- Inference - Out of all users, 537 users actively made a booking. 

# 3) Inactive users

with cte1 as 
(select count(user_id) as Total_Users from users),

cte2 as
(select count(distinct user_id) as Active_Users from bookings)

select (cte1.Total_Users - cte2.Active_Users) as Inactive_Users from cte1,cte2;

-- Inference - 463 out of total users have not made any booking.  

# 4) Repeat Customers 

select count(user_id) as Repeat_Users from
(select u.user_id, count(b.booking_id) as Bookings
from users as u join bookings as b on u.user_id = b.user_id
group by u.user_id
having Bookings >1) as dt;

-- Inference - Out of active users (537), 201 users returned to book again. 

# 5) Users Retention Rate 

with cte1 as 
(select count(distinct user_id) as Active_Users from bookings),

cte2 as 
(select count(user_id) as Repeat_Users from
(select user_id, count(booking_id) as Bookings from bookings group by user_id having Bookings >1)
as dt)
 
select concat(round((cte2.Repeat_Users / cte1.Active_Users) *100,2),'%')
as Users_Retention_Rate from cte1, cte2;

-- Inference - About 37% of users came back, indicating moderate loyalty and room for improvement. 

-- Users Insights 

# 1) Age Group wise booking frequency

select case
when u.age >=18 and u.age <=25 then '18-25'
when u.age >=26 and u.age <=35 then '26-35'
when u.age >=36 and u.age <=45 then '36-45'
when u.age >=46 and u.age <=55 then '46-55'
else '56-70'
end as Age_Group, count(b.booking_id) as Total_Bookings
from users as u join bookings as b on u.user_id = b.user_id
group by Age_Group
order by Total_Bookings desc;

-- Inference - The "55-70" age group has the highest booking frequency (236), showing strong
--             activity among senior users, followed by "46-55" age group with (159) bookings. 

# 2) Top 5 loyal users

select u.User_Name, cast(replace(u.user_id,'U_','') as Unsigned integer) as User_ID,
count(b.booking_id) as Total_Bookings
from users as u join bookings as b on u.user_id = b.user_id
group by u.User_Name, User_ID
order by Total_Bookings desc, User_ID desc
limit 5;

-- Inference - "Keith Dyer" leads loyalty with 6 bookings, while four other users show,
--             strong repeat behavior with 4-5 bookings each.

# 3) Booking frequency of New users Vs Returning users 

select case 
when Bookings = 1 then 'New User'
else 'Returning User'
end as User_Type, sum(Bookings) as Total_Bookings
from
(select u.User_id, count(b.Booking_id) as Bookings 
from users as u join bookings as b on u.user_id = b.user_id
group by u.User_id) as dt
group by User_Type;

-- Inference - Returning users generated (464) bookings,
--             which is higher then the (336) bookings made by new users. 

# 4) Repeat users trend over time

with cte1 as 
(select User_id, count(booking_id) as Bookings
from bookings
group by user_id
having Bookings > 1),

cte2 as 
(select year(booking_date) as Year, month(booking_date) as Month, user_id
from bookings
order by Year, Month)

select cte2.Year, cte2.Month, count(distinct cte1.user_id) as Users
from cte1 join cte2 on cte1.user_id = cte2.user_id
group by cte2.Year, cte2.Month;

-- Inference - Repeat users show stable month-to-month activity,
--             with significant peak in October 2024, and the lowest activity in November 2024.

# 5) Revenue contribution by user type (Returning vs New User) 

with cte1 as 
(select User_id, count(Booking_id) as Bookings, round(sum(Revenue),2) as Revenue
from bookings
group by User_id),

cte2 as 
(select round(sum(Revenue),2) as New_Users_Revenue 
from cte1
where Bookings = 1),

cte3 as 
(select round(sum(Revenue),2) as Returning_Users_Revenue 
from cte1
where Bookings > 1),

cte4 as 
(select cte2.New_Users_Revenue, cte3.Returning_Users_Revenue,
(cte2.New_Users_Revenue + cte3.Returning_Users_Revenue) as Total_Revenue
from cte2,cte3)

select concat(round((New_Users_Revenue / Total_Revenue)*100,2),'%') as New_Users_Revenue_Contribution,
concat(round((Returning_Users_Revenue / Total_Revenue)*100,2),'%') as Returning_Users_Revenue_Contribution
from cte4;

-- Inference - Returning users contribute (59.12%) of the total revenue,
--             which is higher than the (40.88%) contributed by the new users.  

# 6) Age Group wise preferred transaction mode

select Age_Group, Transaction_Mode from
(select *, row_number() over (partition by Age_Group order by Transactions desc) as rnk from
(select case
when u.age >=18 and u.age <=25 then '18-25'
when u.age >=26 and u.age <=35 then '26-35'
when u.age >=36 and u.age <=45 then '36-45'
when u.age >=46 and u.age <=55 then '46-55'
else '56-70'
end as Age_Group, t.Transaction_mode, count(t.transaction_id) as Transactions
from users as u join bookings as b on u.user_id = b.user_id
join transactions as t on b.booking_id = t.booking_id
group by Age_Group, t.transaction_mode) as dt) as dt2
where Rnk = 1;

-- Inference - UPI is the most preferred by "26-35" age group,
--             crdit card by younger and mid-age users, while older groups prefer cash.  

-- Ratings KPI's

# 1) Total Ratings

select count(*) as Total_Ratings from ratings; 

-- Inference - There are total of 800 ratings recorded. 

# 2) Average Customer Rating

select round(avg(Rating_Score),2) as Average_Rating from ratings;

-- Inference - An average score of 4.75 out of 7 which means the users are generally satisfied. 

# 3) Percentage of Positive Ratings

with cte1 as 
(select count(Rating_Score) as Positive_Ratings
from ratings 
where Rating_Score in (5,6,7)), # Positive Ratings Count 

cte2 as 
(select count(ratings) as Total_Ratings
from ratings) # Total Ratings

select concat(round((cte1.Positive_Ratings / cte2.Total_Ratings)*100,2),'%') as `Positive_Ratings%`
from cte1,cte2;

-- Inference - Around 65% of the ratings are positive out of total. 

# 4) Percentage of Negative Ratings

with cte1 as 
(select count(Rating_Score) as Negative_Ratings
from ratings 
where Rating_Score in (1,2)), # Negative Ratings Count 

cte2 as 
(select count(ratings) as Total_Ratings
from ratings) # Total Ratings

select concat(round((cte1.Negative_Ratings / cte2.Total_Ratings)*100,2),'%') as `Negative_Ratings%`
from cte1,cte2;

-- Inference - Only 13.88% ratings are fall on the negative side.

-- Ratings Insights

# 1) City wise average ratings

select h.City, round(avg(r.Rating_Score),2) as Average_Rating
from hotels as h join bookings as b on h.hotel_id = b.hotel_id
join ratings as r on r.booking_id = b.booking_id
group by h.City
order by Average_Rating desc;

-- Inference - Mumbai shows the highest user satisfaction with average rating of 4.92,
--             followed by Pune with 4.76 and Delhi with 4.75 average rating.   

# 2) Top 5 Hotels with highest ratings

select Hotel_Name, Average_Ratings from 
(select h.Hotel_Name, h.Hotel_ID,round(avg(r.Rating_Score),2) as Average_Ratings
from hotels as h join bookings as b on h.hotel_id = b.hotel_id
join ratings as r on r.booking_id = b.booking_id
group by h.Hotel_Name, h.Hotel_ID
order by Average_Ratings desc, h.Hotel_ID desc
limit 5) as dt 
order by Average_Ratings desc, Hotel_Name;

-- Inference - Hotel "Elegant Abode" leads with highest average ratings 7.00,
--             followed by "Hilltop Hideaway" with average ratings 6.50.  

# 3) Rating trend over months

select Year, Month_Name as Month, Average_Ratings 
from
(select year(b.check_in_date) as Year, month(b.check_in_date) as Month,
monthname(b.check_in_date) as Month_Name , round(avg(r.Rating_Score),2) as Average_Ratings
from bookings as b join ratings as r on b.booking_id = r.booking_id
group by Year, Month, Month_Name
order by Year, Month) as dt;

-- Inference - Users ratings fluctuates month by month, having peak in July 2024 (5.17) and 
--             lowest in March 2024 (4.31).  

# 4) Room-Type vs Rating

select b.Room_Type, round(avg(r.Rating_Score),2) as Average_Ratings
from bookings as b join ratings as r on b.booking_id = r.booking_id
group by b.Room_Type
order by Average_Ratings desc;

-- Inference - Standard room-type got the highest average ratings (4.87),
--             indicating strong value for money.  

# 5) First-time vs Repeat users Rating Comparison

with cte1 as 
(select b.user_id, b.booking_id, r.rating_score
from bookings as b join ratings as r on b.booking_id = r.booking_id),

cte2 as 
(select user_id, count(booking_id) as Bookings
from bookings 
group by user_id
having Bookings = 1), # New users

cte3 as 
(select user_id, count(booking_id) as Bookings
from bookings 
group by user_id
having Bookings > 1 ), # Repeat Users

cte4 as 
(select round(avg(cte1.rating_score),3) as New_Users_Average
from cte1 join cte2 on cte1.user_id = cte2.user_id), # Average Rating of New users

cte5 as 
(select round(avg(cte1.rating_score),3) as Repeat_Users_Average
from cte1 join cte3 on cte1.user_id = cte3.user_id) # Average Rating of Repeat users

select cte4.New_Users_Average, cte5.Repeat_Users_Average
from cte4,cte5;

-- Inference - New and Repeat users give almost the same ratings around (4.75).  

# 6) Discount_Bucket wise Ratings

select case
when b.total_discount >=0 and b.total_discount <6 then '0-5%'
when b.total_discount >=6 and b.total_discount <11 then '6-10%'
else '11-15%'
end as Discount_Bucket, round(avg(r.Rating_Score),2) as Average_Ratings
from bookings as b join ratings as r on b.booking_id = r.booking_id
group by Discount_Bucket
order by Average_Ratings desc;

-- Inference - Users who received "11-15%" discount give the highest ratings,
--             indicating strong satisfaction with higher discounts.   
