#!/bin/bash

# Copyright (C) 2007,2008,2009,2010,2011,2012,2013,2014,2015 Ole Tange
# and Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301 USA

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd /etc/yum.repos.d &&
  wget http://download.opensuse.org/repositories/home:tange/CentOS_CentOS-5/home:tange.repo &&
  yum install parallel
