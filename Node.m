classdef Node
    properties
        id;
        x;
        y;
        range;
        speed;
        acquiredSlot=0;
        waitingTillSlot=0;
        frameInfo=zeros(60,1);
        packetQueue=[];
        packetToSend;
        onehopset=zeros(60,1);
        backoff;
    end
    
    methods
        function self = incrementx(self)
            self.x = self.x + self.speed;
        end
        
        function nodes = acquireSlot(self,current_slot,nodes)
            if self.acquiredSlot == 0
                if self.waitingTillSlot == 0
                    nodes(self.id).waitingTillSlot = current_slot;
                elseif self.waitingTillSlot == current_slot
                    %disp("L:"+numel(self.frameInfo));
                    zeroIdx = find(self.frameInfo==0);
                    try
                        self.acquiredSlot = zeroIdx(randi([1 numel(zeroIdx)]));
                        nodes(self.id).acquiredSlot = self.acquiredSlot;
                        nodes(self.id).frameInfo(self.acquiredSlot) = self.id;
                        ohs = self.onehopset;
                        for i = 1:60
                            if ohs(i)~=0
                                nodes(ohs(i)).onehopset(self.acquiredSlot) = self.id;
                                nodes(ohs(i)).frameInfo(self.acquiredSlot) = self.id;
                            end
                        end
                        
                        nodes(self.id).waitingTillSlot = 0;
                        %disp(self.id+" acquired "+self.acquiredSlot);
                    catch
                        disp("No free slot found for: "+self.id);
                        disp(self.id + ":" + self.frameInfo);
                    end
                end
            end
        end
        
        function nodes = acquireHybridSlot(self,nodes)
            if self.acquiredSlot == 0
                free = find(self.frameInfo == 0);
                if numel(free) ~= 0
                    randomFreeSlot = free(randi([1 numel(free)]));
                else
                    randomFreeSlot = randi([1 60]);
                end
                self.acquiredSlot = randomFreeSlot;
                nodes(self.id).acquiredSlot = self.acquiredSlot;
                ohs = self.onehopset;
                for i = 1:60
                    if ohs(i) ~= 0
                        nodes(ohs(i)).onehopset(self.acquiredSlot) = self.id;
                        nodes(ohs(i)).frameInfo(self.acquiredSlot) = self.id;
                    end
                end
            end
        end
        
        function dist = distToNode(self,node)
            dist = norm([self.x;self.y] - [node.x;node.y]);
        end
        
        function nodes = sendFrames(self,nodes,packet)
            for i = 1:numel(nodes)
                if i == self.id
                    continue;
                end
                if self.distToNode(nodes(i)) <= self.range
                    nodes(i).packetQueue = [nodes(i).packetQueue; packet];
                end
            end
        end
        
        function [self,lostSlot] = processPacket(self,current_slot)
            lostSlot = 0;
            if self.acquiredSlot == current_slot
                self.packetQueue = [];
                return;
            end
            if numel(self.packetQueue) == 1
                pack = self.packetQueue;
                if self.onehopset(current_slot) == pack.id
                    unalloc = find(self.frameInfo == 0);
                    for i = unalloc
                        if pack.FI(i) ~= 0
                            self.frameInfo(i) = pack.FI(i);
                        end
                    end
                    try
                        if pack.FI(self.acquiredSlot) == 0
                            disp(self.id + " lost slot");
                            self.acquiredSlot = 0;
                            lostSlot = 1;
                            
                        end
                    catch
                        %disp(self.id + "'s slot:" + self.acquiredSlot);
                    end
                else
                    %disp(self.id + " adding to its list:"+pack.id);
                    self.onehopset(current_slot) = pack.id;
                    self.frameInfo(current_slot) = pack.id;
                end
            else
                self.frameInfo(current_slot) = 0;
                self.onehopset(current_slot) = 0;
                %disp(self.id + " received no packs at "+current_slot);
            end
            self.packetQueue = [];
            self.packetToSend = self.resetPacket();
        end
        
        
        function [nodes,numberOfTransmissions] = sendPackets(self,nodes,current_slot,numberOfTransmissions)
            pack = self.packetToSend;
            if current_slot == self.acquiredSlot
                %disp(self.id+" sending");
                nodes = self.sendFrames(nodes,pack);
            end
            nodes(self.id).packetToSend = self.resetPacket();
        end
        
        function packet = resetPacket(self)
            packet = self.packetToSend;
            packet.FI = self.frameInfo;
        end
        
        
    end
end