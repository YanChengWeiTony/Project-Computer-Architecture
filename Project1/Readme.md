### Project1
The implementation of the pipelined CPU was divided into two phases.
We first developped a single cycle CPU, then modified it to be a pipelined CPU.
In the first phase, 5 modules for IF, ID, EX, MEM, WB stages designed
for the required instruction set were declared at the beginning so that each
stage could be implemented independently. After the implementation of all
the 5 stages, these stages were connected directly without register to form a
single cycle CPU and checked by testing all the instructions could be normally
executed.
In the second phase, the registers between these 5 pipeline stages were inserted into the CPU as well as the forwarding unit and the hazard detector. The
original pipeline stages were also slightly modified to adapt the inserted units.
Finally, after checking the forwarding unit and the hazard detector functioned
correctly, the pipelined CPU implementation was complete.
