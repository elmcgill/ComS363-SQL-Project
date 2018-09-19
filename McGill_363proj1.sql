drop table Enrollment;
drop table Offering;
drop table Course;
drop table Student;
drop table Instructor;
drop table Person;

/*A Item 1 Create Person Table*/
create table Person (
Name char (20),
ID char (9) not null,
Address char (30),
DOB date,
Primary key (ID));

/*A Item 2 Create Instructor Table*/
create table Instructor(
InstructorID char (9) not null References Person(ID),
Rank char (12),
Salary int,
Primary key (InstructorID));

/*A Item 3 Create Student Table*/
create table Student(
StudentID char (9) not null References Person(ID),
Classification char (10),
GPA double,
MentorID char (9) References Instructor(InstructorID),
CreditHours int);

/*A Item 4 Create Course Table*/
create table Course(
CourseCode char (6) not null,
CourseName char (50),
PreReq char (6));

/*A Item 5 Create Offering Table*/
create table Offering(
CourseCode char (6) not null,
SectionNo int not null,
InstructorID char (9) not null References Instructor(InstructorID),
Primary Key (CourseCode, SectionNo));

/*A Item 6 Create Enrollment Table*/
create table Enrollment (
CourseCode char(6) NOT NULL, 
SectionNo int NOT NULL, 
StudentID char(9) NOT NULL references Student, 
Grade char(4) NOT NULL, 
primary key (CourseCode, StudentID), 
foreign key (CourseCode, SectionNo) references Offering(CourseCode, SectionNo));

/*B Item 7 Populate Person Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Person.xml' 
into table Person 
rows identified by '<Person>';

/*B Item 8 Populate Instructor Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Instructor.xml' 
into table Instructor 
rows identified by '<Instructor>';

/*B Item 9 Populate Student Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Student.xml' 
into table Student 
rows identified by '<Student>';

/*B Item 10 Populate Course Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Course.xml' 
into table Course
rows identified by '<Course>';

/*B Item 11 Populate Offering Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Offering.xml' 
into table Offering 
rows identified by '<Offering>';

/*B Item 12 Populate Enrollment Table*/
load xml local infile 'C://Users//Ethan//Desktop//UniversityXML//Enrollment.xml' 
into table Enrollment 
rows identified by '<Enrollment>';

/*C Item 13 List the IDs of students and the IDs of their
Mentors for students who are junior or senior having a GPA above 3.8*/
Select StudentID, MentorID
From db363elmcgill.Student s
where s.Classification = 'Junior' or s.Classification = 'Senior' and s.GPA >= 3.8;

/*C Item 14 List the distinct course codes and
sections for courses that are being taken by sophomore*/
Select distinct CourseCode, SectionNo
from db363elmcgill.Enrollment e, db363elmcgill.Student s
where e.studentID = s.StudentID and s.Classification = 'Sophomore';

/*C Item 15 List the name and salary for mentors of all freshmen*/
Select distinct Name, Salary
from db363elmcgill.Instructor i, db363elmcgill.Student s, db363elmcgill.Person p
where s.MentorID = i.InstructorID and s.Classification = 'Freshman' and p.ID = i.InstructorID;

/*C Item 16 Find the total salary of all instructors who are not offering any course*/
Select sum(Salary)
from db363elmcgill.Instructor i
where i.InstructorID not in (select o.InstructorID from db363elmcgill.Offering o);

/*C Item 17 List all the names and DOBs of students who were born in 1976*/
Select Name, DOB
from db363elmcgill.Person p, db363elmcgill.Student s
where Year(p.DOB) = 1976 and s.StudentID = p.ID;

/*C Item 18 List the names and rank of instructors who neither offer a course nor mentor a student*/
Select Name, Rank
from db363elmcgill.Instructor i, db363elmcgill.Person p
where i.InstructorID not in (select o.InstructorID from db363elmcgill.Offering o) and
i.InstructorID not in (select s.MentorID from db363elmcgill.Student s) and i.InstructorID = p.ID;

/*C Item 19 Find the IDs, names and DOB of the youngest student(s)*/
Select ID, Name, MAX(p.DOB)
from db363elmcgill.Person p, db363elmcgill.Student s
where s.StudentID = p.ID;

/*C Item 20 List the IDs, DOB, and Names of Persons who are neither a student nor a instructor*/
Select ID, DOB, Name
from db363elmcgill.Person p
where p.ID not in (select i.InstructorID from db363elmcgill.Instructor i) and 
p.ID not in (select s.StudentID from db363elmcgill.Student s);

/*C Item 21 For each instructor list his / her name and the number of students he / she mentors*/
Select Name, count(*) as Mentoring_Students
from db363elmcgill.Person p, db363elmcgill.Student s, db363elmcgill.Instructor i
where i.InstructorID = s.MentorID and i.InstructorID = p.ID
group by Name
having count(*) >3;

/*C Item 22 List the number of students and average GPA for each classification.
Your query should not use constants such as "Freshman"*/
Select Classification, count(*), avg(GPA)
from db363elmcgill.Student s
group by Classification
having count(*) >3;

/*C Item 23 Report the course(s) with lowest enrollments.
You should output the course code and the number of enrollments*/
Select CourseCode, count(*) as EnrollCount
from db363elmcgill.Enrollment
group by CourseCode
order by EnrollCount ASC
limit 1;

/*C Item 24 List the IDs and Mentor IDs of students who are taking some course, offered by their mentor*/
Select distinct s.StudentID, MentorID
from db363elmcgill.Student s, db363elmcgill.Enrollment e, db363elmcgill.Offering o
where e.CourseCode = o.CourseCode and o.InstructorID = s.MentorID;

/*C Item 25 List the student id, name, and completed credit hours of all freshman born in or after 1976*/
Select ID, name, s.CreditHours
from db363elmcgill.Person p, db363elmcgill.Student s
where s.Classification = 'Freshman' and p.DOB >= date('1976-01-01') and s.StudentID = p.ID;

/*C Item 26 Insert following information in the database: Student name: Briggs Jason;
ID: 480293439; address: 215 North Hyland Avenue; date of birth: 15th January 1975.
He is a junior with a GPA of 3.48 and with 75 credit hours. His mentor is the instructor with InstructorID 201586985.
Jason Briggs is taking two courses CS311 Section 2 and CS330 Section 1.
He has an �A� on CS311 and �A-� on CS330.*/
Insert into db363elmcgill.Person (Name, ID, Address, DOB)
values ('Briggs Jason', 480293439, '215 North Hyland Avenue', date('1975-01-15'));

Insert into db363elmcgill.Student(StudentID, Classification, GPA, MentorID, CreditHours)
values (480293439, 'Junior', 3.48, 201586985, 75);

Insert into db363elmcgill.Enrollment(CourseCode, SectionNo, StudentID, Grade)
values('CS311', 2, 480293439, 'A');

Insert into db363elmcgill.Enrollment(CourseCode, SectionNo, StudentID, Grade)
values('CS330', 1, 480293439, 'A-');

Select *
From Person P
Where P.Name= 'Briggs Jason';

Select *
From Student S
Where S.StudentID= 480293439;

Select *
From Enrollment E
Where E.StudentID = 480293439;

/*C Item 27 Next, delete the records of students from the database who have a GPA less than 0.5*/
Delete from Enrollment
where StudentID in (Select StudentID from db363elmcgill.Student s
where GPA < .5);

Delete from Student
where GPA < .5;

Select *
From Student S
Where S.GPA < 0.5;

/*C Item 28 Update the instructor Ricky Ponting's salary to reflect a 10% raise provided there are at
least 5 different students enrolled in his courses with a grade of A*/
Select Salary
from db363elmcgill.Instructor, db363elmcgill.Person
where Person.Name = 'Ricky Ponting' and Person.ID = Instructor.InstructorID;

update Instructor
set Salary = Salary * 1.1
where InstructorID in (Select distinct count(*)
	from db363elmcgill.Person p, db363elmcgill.Enrollment e, db363elmcgill.Offering o
	where p.Name = 'Ricky Ponting' and o.InstructorID = p.ID and e.Grade = 'A'
	group by StudentID
	having count(*)>5);

Select Salary
from db363elmcgill.Instructor, db363elmcgill.Person
where Person.Name = 'Ricky Ponting' and Person.ID = Instructor.InstructorID;

/*C Item 29 Insert the following information into the Person table. Name: Trevor Horns;
ID: 000957303; Address: 23 Canberra Street; date of birth: 23rd November 1964*/
Insert into db363elmcgill.Person (Name, ID, Address, DOB)
values ('Trevor Horns', 000957303, '23 Canberra Street', date('1964-11-23'));

Select Name, ID, Address, DOB
from db363elmcgill.Person p
where p.Name = 'Trevor Horns';

/*C Item 30 Delete the record for the student Jan Austin from Enrollment and Student tables
Her record from the Person table should not be deleted*/
Delete from Enrollment
where StudentID in (Select ID from db363elmcgill.Person p
where StudentID = p.ID);

Delete from Student
where StudentID in (Select ID from db363elmcgill.Person p
where StudentID = p.ID);

Select StudentID
from db363elmcgill.Enrollment m, db363elmcgill.Person p
where p.Name = 'Jan Austin' and p.ID = m.StudentID;

Select StudentID
from db363elmcgill.Student s, db363elmcgill.Person p
where p.Name='Jan Austin' and p.ID = s.StudentID;

Select Name, ID, Address, DOB
from db363elmcgill.Person
where Person.Name = 'Jan Austin';

