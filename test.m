clear;
import Packet;
import Node;

xmin= 0;
xmax= 1000;
n = 60;
x_s = round(xmin+rand(1,n)*(xmax-xmin));
x_s = sort(x_s);
y_s = [5;10;15];
vehicles(50,1) = Node();
speeds = [10;20;30];
for i = 1:n
    vehicles(i).id = i;
    vehicles(i).x = x_s(i);
    vehicles(i).y = y_s(randi([1 3]));
    vehicles(i).packetToSend = Packet(vehicles(i));
    vehicles(i).range = 300;
    vehicles(i).acquiredSlot = randi([1 60]);
    vehicles(i).frameInfo(i) = 1;
    vehicles(i).speed = speeds(randi([1 3]));
end

% dataPacket = Packet(nodes(1));
% dataPacket.type = "data";
% dataPacket.sourceId = 1;
% dataPacket.relayId = 1;
% dataPacket.destinationId = n;
% nodes(1).packetQueue = dataPacket;

disp(vehicles(3).x);
success = false;
current_slot = 1;
round = 1;
notset = true;
numberOfTransmissions = zeros(n,1);
collisions = 0;
while round<6
    plot([vehicles.x],[vehicles.y],"r>");
    pause(0.2);
    for i = 1:n
        vehicles = vehicles(i).acquireSlot(current_slot,vehicles);
    end
    
    for i = 1:n
        [vehicles,numberOfTransmissions] = vehicles(i).sendPackets(vehicles,current_slot,numberOfTransmissions);
    end
    [vehicles,lostSlot] = arrayfun( @(x) x.processPacket(current_slot), vehicles);
    for s = 1:numel(lostSlot)
        if lostSlot(s) == 1
            collisions = collisions + 1;
        end
    end
    vehicles = arrayfun( @(x) x.incrementx(), vehicles);
    if current_slot == 60
        current_slot = 1;
        disp("round "+round+" over");
        round = round + 1;
    else
        current_slot = current_slot + 1;
    end
end

disp(collisions);