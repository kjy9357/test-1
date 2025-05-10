#!/bin/bash
if [ $# -ne 1 ]
then 
	echo "usage: ./2025_OSS_Project1.sh file"
	exit 1
fi
file="$1"
echo "************OSS1 - Project1************"
echo "*      StudentID : 12243873       *"
echo "*      Name: JiYun Kim            *"
echo "***************************************"
echo
n=1
while [ $n -ne 7 ]
do 
	echo "[MENU]"
	echo "1.Search player stats by name in MLB data"
	echo "2.List top 5 players by SLG value"
	echo "3.Analyze the team stats - average age and total home runs"
	echo "4.Compare players in different age groups"
	echo "5.Search the players who meet specific statistical conditions"
	echo "6.Generate a performance report (formatted data)"
	echo "7.Quit"
	read -p "Enter your COMMAND (1~7) : " n

	case "$n" in
		1)
			read -p "Enter a player name to search: " name
			echo
			echo "Player stats for \"$name\":"
			cat "$file" | awk -F',' -v name="$name" '$2==name {print "Player: "$2 ", Team: "$4", Age: "$3",WAR: "$6", HR: "$14", BA: "$20}'
			;;
		2)
			read -p "Do you want to see the top 5 players by SLG? (y/n):" select
			echo
			if [ $select = "y" ]
			then
				echo "***Top 5 Players by SLG***"
				cat $file | sort -t',' -k22 -nr | awk -F',' '
				$8>502 {print ++num". "$2" (Team: "$4") - SLG: "$22", HR: "$14", RBI: "$15}
				' | head -n 5   
			fi
			;;
		3)
			read -p "Enter team abbreviation (e.g., NYY, LAD, BOS): " teamName
			echo
			if awk -F',' -v teamName="$teamName" '$4==teamName {found=1} END { exit !found }' "$file"
			then
				echo "Team stats for $teamName:"
				cat $file | awk -F',' -v teamName="$teamName" '
			$4==teamName {
			sumAge+=$3;
		       	sumHR+=$14;
		       	sumRBI+=$15;
			++num;
			}
			END {
			printf "Average age: %.1f\n", sumAge/num 
			print "Total home runs: " sumHR
			print"Total RBI: " sumRBI
			}'
		else
			echo "Non-existent team is entered."
		fi
			;;
		4)
			echo
			echo "Compare players by age groups: "
			echo "1. Group A (Age<25)"
			echo "2. Group B (Age 25-30)"
			echo "3. Group C (Age>30)"
			read -p "Select age group (1-3): " select
			echo

			if [ $select = "1" ]
			then
				echo "Top 5 by SLG in Group A(Age<25):"
				awk -F',' '($3<25&&$8>502)' "$file" | sort -t',' -k22 -nr | awk -F',' ' 
				{print $2" ("$4") - Age: "$3", SLG: "$22", BA: "$20", HR: "$14} ' | head -n 5
			elif [ $select = "2" ]
			then
				echo "Top 5 by SLG in Group B(Age 25-30):"
				awk -F',' '($3>=25 && $3<=30 && $8>502)' "$file" | sort -t',' -k22 -nr | awk -F',' '
				{print $2" ("$4") - Age: "$3", SLG: "$22", BA: "$20", HR: "$14}' | head -n 5
			elif [ $select = "3" ]
			then
				echo "Top 5 by SLG in Group C(Age>30):"
				awk -F',' '($3>30&&$8>502)' "$file" | sort -t',' -k22 -nr | awk -F',' '
				{print $2" ("$4") - Age: "$3", SLG: "$22", BA: "$20", HR: "$14}' | head -n 5

			fi
			
			;;
		5)
			echo
			echo "Find Players with specific criteria"
			read -p "Minimum home runs: " HR
			read -p "Minimun batting average (e.g., 0.280): " BA
			echo
			echo "Players with HR≥$HR and BA≥$BA:"
			cat "$file" | tail -n +2 | awk -F',' -v HR="$HR" -v BA="$BA" '
			{
				if ($14>=HR && $20>=BA && $8>502)
					print $2" ("$4") - HR: "$14", BA: "$20", RBI: "$15", SLG: "$22}' | sort -t':' -k2 -nr
			;;
		6)
			today=$(date +%Y/%m/%d)
			echo "Generate a formatted player report for which team?"
			read -p "Enter team abbreviation (e.g., NYY,LAD,BOS): " teamName
			cat $file | sort -t',' -k22 -nr | awk -F',' -v teamName="$teamName" -v today="$today" '
			BEGIN {
			print "================== "teamName" PLAYER REPORT =================="
			print "Date: "today
			print "------------------------------------------------------"
			printf "%-20s %4s %4s %5s %5s %5s\n","PLAYERS","HR","RBI","AVG","OBP","OPS"
			print "------------------------------------------------------"
		}
		( $4 == teamName ) {
			printf "%-20s %4s %4s %5s %5s %5s\n", $2, $14, $15, $20, $21, $23
			count++
	}
	END {
	print "------------------------------------------------------"
	print "TEAM TOTALS: "count" players"
	}
		'
			;;
		7)
			echo "Have a good day!"
			exit 0;;
		*)
			exit 0;;
	esac

	echo
done

