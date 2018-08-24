#!/bin/bash

function list()
{

}

function printHelp()
{

}

function init()
{
    while getopts "d" arg
    do
        list=true;
        download=false;
        case ${arg} in
            d)
                list=false;
                download=true;
                ;;
            h)
                printHelp;
                exit;
                ;;
            *)
                printHelp;
                exit;
                ;;
        esac
    done
}

function main()
{
    init $@;
}

main $@;
