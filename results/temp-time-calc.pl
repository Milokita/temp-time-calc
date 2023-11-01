#!usr/bin/perl -w

use strict;
use File::Path qw(make_path);
use Cwd qw(abs_path);
use Carp;
use Time::Piece;


##########################基本说明########################
# 该脚本用于计算特定格式的日志文件当中，每个read处理完成所需的时间。处理完成后，会生成一列代表时间差的数字结果。
# example_1: perl /lustre/liugx/software/Gexin_perl_scripts/temp-time-calc.pl ./fast.log ./
usage() if @ARGV != 2;

sub usage {
        my $usage = << "END_USAGE";

		Description: This script is specifically designed to calculate the time difference between the completion of two processings in a log file of a specific format.  
        
		Author: Gexin Liu	1155189737\@link.cuhk.edu.hk	10/31/2023	
        Usage: perl $0 input_file output_root

END_USAGE
print "$usage";
exit(1);
};

##########################一些需要的变量参数########################

# 输入文件的路径和输出最终结果文件的路径。
my $input_file  = abs_path($ARGV[0]);
my $output_root = abs_path($ARGV[1]);

# 一些之后需要用到的变量先定义。
## 保存read loaded信息的数组。原因在于我的思路是先保存找到的loaded的信息，之后如果找到了completed信息，再和这个数组进行匹配比较，如果相同的话就进行时间计算。然后删掉数组中对应的loaded的元素。这样比较省内存，效率也会高一点。
my @read_load_store;
## 记录每行时间信息的数组。
my @time_info_store;
## 记录时间差的变量。
my $time_diff_store           = "Read_ID\tTime_spent\n";
## 记录未完成的read信息的变量。
my $unfinished_load_read_info = "Time\tRead_ID\tStatus\n";
## 为后续的while循环计个数。
my $log_line_count            = 0;
## 为之后计算时间差的while循环计数，这里之所以从1开始，因为是从后一位减前一位。
my $time_info_store_count     = 1;

##########################正式开始########################


# 我希望输出的文件名为原来的文件名加上一个时间差计算(time_diff_calc)的后缀的txt文件。
my @input_file_part                  = split(/\//,$input_file);
my $file_name                        = $input_file_part[-1];
## 输出文件名，就是在原文件名的基础上加上_time_diff_calc以及txt的后缀名即可。
my $output_file_name                 = "$file_name"."_time_diff_calc.txt";
## 输出未完成的read信息，以防有些read仅仅loaded但未完成分析。
my $output_unfinished_read_file_name = "$file_name"."_unfinished_read_info.txt";

# 读取并处理文件。
print("Reading and processing the log file \'$input_file\'...\n");
open(my $logfile_read, "<", "$input_file") || croak "can't open the file!!!";

while (my $each_line_logfile = <$logfile_read>){
	
	chomp($each_line_logfile);
	## 这里的要求是匹配到含有read以及加载完成信息的行。
	if ($each_line_logfile =~ m{([0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+).*has\sbeen\sloaded\.}xms){
		
		my $matched_loaded_read_info = $1;
		my @each_loaded_line_info    = split(/\s+/,$each_line_logfile);
		my $single_loaded_time_info  = $each_loaded_line_info[0]." ".$each_loaded_line_info[1]."\t".$1."\t".$each_loaded_line_info[-1];
		# print($single_loaded_time_info,"\n");
		push(@read_load_store, $single_loaded_time_info);
		
	}
	elsif ($each_line_logfile =~ m{([0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+\-[0-9a-z]+).*completed\.}xms){ ### 然后寻找对应的completed的信息。
		
		### 首先获取到完成了的read序号信息以及日期信息。
		my $matched_completed_read_info = $1;
		my @each_completed_line_info    = split(/\s+/,$each_line_logfile);
		my $completed_read_time         = $each_completed_line_info[0]." ".$each_completed_line_info[1];
		# my $single_completed_time_info  = $completed_read_time."\t".$1."\t".$each_completed_line_info[-1];
		# print($single_completed_time_info,"\n");
		
		### 然后尝试与之前保存的loaded信息里的每一行进行匹配。首先计个数。
		my $loaded_completed_count = 0;
		while ($loaded_completed_count < @read_load_store){
			
			#### 这里有一个问题，completed信息，需要找最近的对应的load信息，也就是需要数组从后往前读，通过取负数索引的办法实现。
			my $new_index = -1 - $loaded_completed_count;
			
			#### 把这个索引对应的loaded的信息获取一下。以tab进行分割的话，那么第0号元素就是时间信息，而第1号元素就是read序号信息。
			my @each_store_loaded_info = split("\t",$read_load_store[$new_index]);
			#### 如果相同的话，那么我们就要开始进行时间加减的计算了。

			if ($matched_completed_read_info eq $each_store_loaded_info[1]){
				
				# print($matched_completed_read_info,"\n");
				##### 首先得到前一个时间(loaded)和后一个时间的信息。(completed)
				my $time1 = $each_store_loaded_info[0];
				my $time2 = $completed_read_time;
				
				##### 获取秒数的小数点部分。
				my @time1_part       = split(/\./, $time1);
				my $seconds_decimal1 = $time1_part[-1];
				my $decimal_places1  = length($seconds_decimal1);
				my $real_seconds1    = $seconds_decimal1 / 10 ** $decimal_places1;
				
				my @time2_part       = split(/\./, $time2);
				my $seconds_decimal2 = $time2_part[-1];
				my $decimal_places2  = length($seconds_decimal2);
				my $real_seconds2    = $seconds_decimal2 / 10 ** $decimal_places2;
				
				##### 获取到小数部分之后，把小数部分去掉，仅保留整数部分，因为后面获取绝对时间的时候，最小单位是整数的秒。
				$time1 =~ s{\.[0-9]+}{}g;
				$time2 =~ s{\.[0-9]+}{}g;
				
				##### 时间转换。
				my $dt1 = Time::Piece->strptime($time1, "%Y-%m-%d %H:%M:%S");
				my $dt2 = Time::Piece->strptime($time2, "%Y-%m-%d %H:%M:%S");
				
				##### 获得绝对时间（以秒为单位）。
				my $epoch_time1 = $dt1->epoch;
				my $epoch_time2 = $dt2->epoch;
				
				##### 然后将小数部分加上去。
				my $total_time1 = $epoch_time1 + $real_seconds1;
				my $total_time2 = $epoch_time2 + $real_seconds2;
				
				##### 计算时间差值。
				my $difference  = $total_time2 - $total_time1;
				##### 只保留6位小数。
				my $difference_six_decimal_places = sprintf("%.6f",$difference);
				# print($difference6,"\n");
				
				##### 记录下时间差的信息。
				$time_diff_store .= "$matched_completed_read_info"."\t"."$difference_six_decimal_places"."\n";
				##### 然后我们删掉loaded数组当中的这个元素，节省内存。然后再把数组颠倒回去。
				splice(@read_load_store, $new_index, 1);
				
				##### 为了防止有些数据load了不止一次，但只有一次complete信息，于是排到第一次就要退出循环。
				last;
			}
			$loaded_completed_count++;
		}

	}
	$log_line_count++;
	
}

close($logfile_read) || croak "can't close the file!!!";
print("The time infomation of log file \'$input_file\' has been successfully processed\n");

# 最后输出结果文件,第一列是read序号信息，第二列是从loaded到completed所花费的时间。
if (defined($time_diff_store)){
	open(my $time_diff_store_out, ">", "$output_root/$output_file_name") || croak "can't open in the file!!!";
	print {$time_diff_store_out}($time_diff_store)                       || croak "can't write in the file!!!";
	close($time_diff_store_out)                                          || croak "can't close the file!!!";
	print("The final results of the differences of time have been saved successfully in the $output_root/$output_file_name\n");
	$time_diff_store = "Read_ID\tTime_spent\n";
}
# 如果还有没有处理完的，同样也输出。
if (scalar(@read_load_store) > 0){
	
	foreach my $single_unfinished_read_load_info (@read_load_store){
		$unfinished_load_read_info .= "$single_unfinished_read_load_info\n";
	}
	
	open(my $unfinished_loaded_out, ">", "$output_root/$output_unfinished_read_file_name") || croak "can't open in the file!!!";
	print {$unfinished_loaded_out} $unfinished_load_read_info                              || croak "can't write in the file!!!";
	close($unfinished_loaded_out)                                                          || croak "can't close the file!!!";
	print("The unfinished read infomation have been saved successfully in the $output_root/$output_unfinished_read_file_name\n");
	$unfinished_load_read_info = "";
}


