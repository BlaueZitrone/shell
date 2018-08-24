#!/bin/bash

function Check()
{
	echo -en "\033[1;33m[Check]$*\033[0m";
}
function Debug()
{
	echo -en "\033[1;34m[Debug]$*\033[0m";
}
function Info()
{
	echo -en "\033[1;32m[Info]$*\033[0m";
}
function Error()
{
	echo -en "\033[1;41m[Error]$*\033[0m";
}
function Processing()
{
	echo -en "\033[1;32;5m[Processing]$*\033[39;49;0m";
}
function Input()
{
	echo -en "\033[1;33;5m[Input]$*\033[39;49;0m";
}
function Red()
{
	echo -en "\033[1;31;5m$*\033[0m";
}