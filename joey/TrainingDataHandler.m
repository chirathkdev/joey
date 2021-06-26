//
//  TrainingDataHandler.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/12/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "TrainingDataHandler.h"

@interface TrainingDataHandler() <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSMutableArray *textsWithOpinions;

@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;

@property (nonatomic, strong) NSMutableArray *opnionsArray;

@property (nonatomic, strong) NSMutableString *textTagValue;

@property (nonatomic, strong) NSString *currentElement;

@end

@implementation TrainingDataHandler

- (NSMutableArray *)initializeDataWithXMLParser {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ABSA-15_Restaurants_Train_Final" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    self.xmlParser = [[NSXMLParser alloc] initWithData:data];
    self.xmlParser.delegate = self;
    
    self.textTagValue = [NSMutableString new];
    
    [self.xmlParser parse];
    
    return _textsWithOpinions;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    self.textsWithOpinions = [[NSMutableArray alloc] init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    NSLog(@"Training data generation successful");
//    NSLog(@"%@", _textsWithOpinions);
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    // If the current element name is equal to "sentence" then initialize the temporary dictionary.
    if ([elementName isEqualToString:@"sentence"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
        self.opnionsArray = [NSMutableArray new];
        
    } else if ([elementName isEqualToString:@"Opinion"]) {
        
        NSString *opinionTargetAttribute = [attributeDict objectForKey:@"target"];
        NSString *opinionCategoryAttribute = [attributeDict objectForKey:@"category"];
        NSString *opinionPolaritryAttribute = [attributeDict objectForKey:@"polarity"];
        
        NSMutableDictionary *opinion = [NSMutableDictionary new];
        [opinion setObject:[NSString stringWithString:opinionTargetAttribute] forKey:@"opinionTarget"];
        [opinion setObject:[NSString stringWithString:opinionCategoryAttribute] forKey:@"opinionCategory"];
        [opinion setObject:[NSString stringWithString:opinionPolaritryAttribute] forKey:@"opinionPolarity"];
        
        [self.opnionsArray addObject:[[NSDictionary alloc] initWithDictionary:opinion]];
        
    }
    
    // Keep the current element.
    self.currentElement = elementName;
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"sentence"]) {
        
        // If the closing element equals to "sentence" then the all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data array.
        [self.textsWithOpinions addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
        
    } else if ([elementName isEqualToString:@"text"]){
        
        // If the text element was found then store it.
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.textTagValue] forKey:@"text"];
        
    } else if ([elementName isEqualToString:@"Opinions"]){
        
        [self.dictTempDataStorage setObject:_opnionsArray forKey:@"opinions"];
    }
    
    // Clear the mutable string.
    [self.textTagValue setString:@""];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    // Store the found characters if only we're interested in the current element.
    if ([self.currentElement isEqualToString:@"text"]) {
        
        if (![string isEqualToString:@"\n"]) {
            
            [self.textTagValue appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
}


@end
