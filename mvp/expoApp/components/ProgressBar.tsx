import React from 'react';
import { 
    StyleSheet, 
    View, 
    Text, 
    TouchableOpacity, 
    StatusBar,
    Platform, 
  useWindowDimensions
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

// Type definitions
interface ProgressBarProps {
  current: number | undefined;
  total: number | undefined;
  percentage: number | undefined;
}

// Progress Bar Component
const ProgressBar: React.FC<ProgressBarProps> = ({ current, total, percentage }) => {
  if (current === undefined || total === undefined || percentage === undefined) {
    return null;
  }
  
  const { width } = useWindowDimensions();
  const isNarrowScreen = width < 350;
  
  // Generate progress dots
  const dots = [];
  // Reduce number of dots on narrow screens
  const visibleDots = isNarrowScreen ? Math.min(5, total) : total;
  
  for (let i = 0; i < visibleDots; i++) {
    dots.push(
      <View 
        key={i} 
        style={[
          styles.progressDot, 
          i < current ? styles.progressDotActive : null
        ]} 
      />
    );
  }
  
  return (
    <View style={styles.progressContainer}>
      <View style={styles.progressHeader}>
        <Text style={[styles.progressText, isNarrowScreen && { fontSize: 14 }]}>
          Question {current} of {total}
        </Text>
        <TouchableOpacity>
          <Text style={[styles.viewAllText, isNarrowScreen && { fontSize: 14 }]}>View All</Text>
        </TouchableOpacity>
      </View>
      
      <View style={styles.progressPercentage}>
        <Text style={[styles.percentageText, isNarrowScreen && { fontSize: 14 }]}>
          {percentage}% complete
        </Text>
      </View>
      
      <View style={styles.progressBarBackground}>
        <LinearGradient
          colors={['#9370DB', '#FFFFFF', '#90EE90']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={[styles.progressBarFill, { width: `${percentage}%` }]}
        />
      </View>
      
      <View style={styles.progressDots}>
        {dots}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  progressContainer: {
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 20 : StatusBar.currentHeight ? StatusBar.currentHeight + 10 : 30,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  progressText: {
    color: '#FFF',
    fontSize: 16,
  },
  viewAllText: {
    color: '#FFF',
    fontSize: 16,
  },
  progressPercentage: {
    marginTop: 5,
  },
  percentageText: {
    color: '#9370DB',
    fontSize: 16,
    fontWeight: 'bold',
  },
  progressBarBackground: {
    height: 5,
    backgroundColor: '#333',
    borderRadius: 5,
    marginTop: 10,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 5,
  },
  progressDots: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  progressDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#333',
  },
  progressDotActive: {
    backgroundColor: '#FFF',
  },
});

export default ProgressBar;