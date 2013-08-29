#!/usr/sbin/dtrace -s

/*
 * Usage: sudo ruby-latency.d -p $ruby_pid
 */

#pragma D option quiet
#pragma D option dynvarsize=100m

dtrace:::BEGIN
{
  printf("Tracing ruby process %d... Hit Ctrl-C to end.\n", $target);
}

ruby$target:::method-entry {
  self->start = timestamp;
}

ruby$target:::method-return /self->start/ {
  @time[copyinstr(arg0), copyinstr(arg1), copyinstr(arg2)] = quantize(timestamp - self->start);
  self->start = 0;
}

dtrace:::END {
  printf("\nresults:\n");
  printa(@time);
  trunc(@time);
}
